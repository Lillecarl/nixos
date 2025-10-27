#!/usr/bin/env python3
"""
nix-touch: Update Nix store path registration times for LRU garbage collection

This tool updates the registrationTime field in the Nix database for a store path
and its dependencies, effectively marking them as "recently used" for GC purposes.
"""

import argparse
import sqlite3
import sys
import os
from sqlite3 import Connection
from pathlib import Path


def get_runtime_deps(conn: Connection, storePath: Path) -> list[Path]:
    """Get store path and all runtime dependencies"""

    sql = """
    WITH RECURSIVE closure(id) AS (
        -- Start with the target store path
        SELECT id FROM ValidPaths WHERE path = ?

        UNION

        -- Recursively follow runtime dependencies
        SELECT r.reference
        FROM closure c
        JOIN Refs r ON c.id = r.referrer
    )
    SELECT v.path FROM ValidPaths v
    WHERE v.id IN (SELECT DISTINCT id FROM closure);
    """

    return [Path(row[0]) for row in conn.execute(sql, (str(storePath),)).fetchall()]


def get_runtime_and_build_deps(conn: Connection, storePath: Path) -> list[Path]:
    """Get store path, runtime deps, and build dependencies"""

    sql = """
    WITH RECURSIVE closure(id) AS (
        -- Start with the target store path
        SELECT id FROM ValidPaths WHERE path = ?

        UNION

        -- Follow runtime dependencies
        SELECT r.reference
        FROM closure c
        JOIN Refs r ON c.id = r.referrer

        UNION

        -- Follow what built this path (deriver)
        SELECT v.id
        FROM closure c
        JOIN ValidPaths vp ON c.id = vp.id
        JOIN ValidPaths v ON vp.deriver = v.path
        WHERE vp.deriver IS NOT NULL

        UNION

        -- Follow deriver's dependencies (build tools, stdenv, etc)
        SELECT r.reference
        FROM closure c
        JOIN ValidPaths vp ON c.id = vp.id
        JOIN ValidPaths drv ON vp.deriver = drv.path
        JOIN Refs r ON drv.id = r.referrer
        WHERE vp.deriver IS NOT NULL
    )
    SELECT v.path FROM ValidPaths v
    WHERE v.id IN (SELECT DISTINCT id FROM closure);
    """

    return [Path(row[0]) for row in conn.execute(sql, (str(storePath),)).fetchall()]


def touch_paths(conn: Connection, paths: list[Path]) -> int:
    """Update registration time for list of store paths"""

    if not paths:
        return 0

    sql = """
    UPDATE ValidPaths
    SET registrationTime = strftime('%s', 'now')
    WHERE path = ?;
    """

    with conn:
        conn.executemany(sql, [(str(path),) for path in paths])
    return len(paths)


def validate_store_path(conn: Connection, storePath: Path) -> Path:
    """Validate and resolve store path"""
    # Resolve symlinks like ./result
    if Path(storePath).is_symlink():
        resolved = Path(storePath).resolve()
        if str(resolved).startswith("/nix/store/"):
            storePath = resolved

    if not storePath.is_relative_to(Path("/nix/store")):
        raise Exception(f"Invalid store path: {storePath}")

    exists = conn.execute(
        "SELECT 1 FROM ValidPaths WHERE path = ?", (str(storePath),)
    ).fetchone()
    if not exists:
        raise Exception(f"Store path not found in database: {storePath}")

    return storePath


def show_path_info(conn: Connection, storePath: Path):
    """Show information about store path"""
    result = conn.execute(
        """
        SELECT registrationTime
        FROM ValidPaths WHERE path = ?
    """,
        (str(storePath),),
    ).fetchone()

    if not result:
        print(f"No information found for {storePath}")
        return

    reg_time = result[0]
    import time

    reg_date = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(reg_time))

    print(f"Path: {storePath}")
    print(f"Registration time: {reg_date}")
    print(f"Runtime deps: {len(get_runtime_deps(conn, storePath))}")
    print(f"Buildtime deps: {len(get_runtime_and_build_deps(conn, storePath))}")


def main():
    parser = argparse.ArgumentParser(
        description="Update Nix store path registration times for LRU garbage collection",
        epilog="""
Examples:
  %(prog)s /nix/store/abc123-hello-1.0          # Touch runtime dependencies
  %(prog)s ./result --build-deps                # Touch build + runtime deps
  %(prog)s /nix/store/xyz --info               # Show path information
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument("store_path", help="Nix store path to touch")
    parser.add_argument(
        "--build-deps", action="store_true", help="Also touch build-time dependencies"
    )
    parser.add_argument(
        "--info", action="store_true", help="Show path information and exit"
    )

    args = parser.parse_args()

    try:
        db_path = Path(os.environ.get("NIX_STATE_DIR", "/nix/var/nix")) / "db/db.sqlite"
        if not db_path.exists():
            raise Exception(f"Nix database not found: {db_path}")

        if os.geteuid() == 0:
            db_uri = f"file:{db_path}?mode=rwc&immutable=0"
        else:
            # Setting immutable can fail spectacularly (read invalid data) but
            # it won't corrupt the database so it doesn't really matter
            db_uri = f"file:{db_path}?mode=ro&immutable=1"
        with sqlite3.connect(db_uri, uri=True) as conn:
            store_path = validate_store_path(conn, Path(args.store_path))

            if args.info:
                show_path_info(conn, store_path)
                return

            if os.geteuid() != 0:
                print("Touching requires Super Cow Powers!")
            else:
                if args.build_deps:
                    paths = get_runtime_and_build_deps(conn, store_path)
                else:
                    paths = get_runtime_deps(conn, store_path)

                count = touch_paths(conn, paths)
                print(f"Updated registration time for {count} store paths")
    except Exception as e:
        print(f"Error: {e.with_traceback}")
        sys.exit(1)


if __name__ == "__main__":
    main()
