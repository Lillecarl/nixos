#!/usr/bin/env python3
"""
nix-touch: Update Nix store path registration times for LRU garbage collection

This tool updates the registrationTime field in the Nix database for store paths
and their dependencies, effectively marking them as "recently used" for GC purposes.
"""

import argparse
import sqlite3
import sys
import os
from sqlite3 import Connection
from pathlib import Path


def get_runtime_deps(conn: Connection, storePaths: list[Path]) -> list[Path]:
    """Get store paths and all their runtime dependencies"""
    if not storePaths:
        return []

    placeholders = ", ".join("?" for _ in storePaths)
    sql = f"""
    WITH RECURSIVE closure(id) AS (
        -- Start with the target store paths
        SELECT id FROM ValidPaths WHERE path IN ({placeholders})

        UNION

        -- Recursively follow runtime dependencies
        SELECT r.reference
        FROM closure c
        JOIN Refs r ON c.id = r.referrer
    )
    SELECT v.path FROM ValidPaths v
    WHERE v.id IN (SELECT DISTINCT id FROM closure);
    """

    params = [str(p) for p in storePaths]
    return [Path(row[0]) for row in conn.execute(sql, params).fetchall()]


def get_runtime_and_build_deps(conn: Connection, storePaths: list[Path]) -> list[Path]:
    """Get store paths, their runtime deps, and their build dependencies"""
    if not storePaths:
        return []

    placeholders = ", ".join("?" for _ in storePaths)
    sql = f"""
    WITH RECURSIVE closure(id) AS (
        -- Start with the target store paths
        SELECT id FROM ValidPaths WHERE path IN ({placeholders})

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

    params = [str(p) for p in storePaths]
    return [Path(row[0]) for row in conn.execute(sql, params).fetchall()]


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


def validate_store_paths(conn: Connection, storePaths: list[Path]) -> list[Path]:
    """Validate and resolve a list of store paths."""
    validated_paths = []
    invalid_paths = []

    for p in storePaths:
        path = p.resolve()

        if not path.is_relative_to(Path("/nix/store")):
            invalid_paths.append(f"Invalid store path: {p} ({path})")
            continue

        exists = conn.execute(
            "SELECT 1 FROM ValidPaths WHERE path = ?", (str(path),)
        ).fetchone()
        if not exists:
            invalid_paths.append(f"Store path not found in database: {p}")
            continue

        validated_paths.append(path)

    if invalid_paths:
        raise Exception("\n".join(invalid_paths))

    return validated_paths


def show_paths_info(conn: Connection, storePaths: list[Path]):
    """Show aggregated information about store paths"""
    import time

    # Show registration time only for a single path for clarity
    if len(storePaths) == 1:
        storePath = storePaths[0]
        result = conn.execute(
            "SELECT registrationTime FROM ValidPaths WHERE path = ?", (str(storePath),)
        ).fetchone()

        if result:
            reg_time = result[0]
            reg_date = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(reg_time))
            print(f"Path: {storePath}")
            print(f"Registration time: {reg_date}")

    # Aggregated dependency counts
    runtime_deps = get_runtime_deps(conn, storePaths)
    build_deps = get_runtime_and_build_deps(conn, storePaths)

    print(f"Total unique runtime deps: {len(runtime_deps)}")
    print(f"Total unique buildtime deps: {len(build_deps)}")


def get_db_uri(db_path: Path) -> str:
    if os.geteuid() == 0:
        return f"file:{db_path}?mode=rwc&immutable=0"
    else:
        # For non-root, first try a standard read-only connection.
        db_uri = f"file:{db_path}?mode=ro"
        try:
            # Test the connection to see if it works without immutable.
            # We need to run a query against a table to trigger wal and shm
            # creation
            with sqlite3.connect(db_uri, uri=True) as testConn:
                testConn.execute("SELECT 1 FROM ValidPaths LIMIT 1;")
                pass
        except Exception:
            # If there are no existing -wal and -shm files SQLite tries to
            # create them even in "ro" mode, but it also means the DB is in a
            # consistent state(?) so we can open immutable and have the latest
            # data
            db_uri = f"file:{db_path}?mode=ro&immutable=1"
        return db_uri


def main():
    parser = argparse.ArgumentParser(
        description="Update Nix store path registration times for LRU garbage collection",
        epilog="""
Examples:
  %(prog)s /nix/store/abc-hello /nix/store/def-world # Touch runtime dependencies for multiple paths
  %(prog)s ./result --build-deps                     # Touch build + runtime deps
  %(prog)s /nix/store/xyz                            # Show path information
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )

    parser.add_argument("store_paths", nargs="+", help="Nix store path(s) to touch")
    parser.add_argument(
        "--build-deps", action="store_true", help="Also touch build-time dependencies"
    )

    args = parser.parse_args()

    try:
        db_path = Path(os.environ.get("NIX_STATE_DIR", "/nix/var/nix")) / "db/db.sqlite"
        if not db_path.exists():
            raise Exception(f"Nix database not found: {db_path}")

        with sqlite3.connect(get_db_uri(db_path), uri=True) as conn:
            validated_paths = validate_store_paths(
                conn, [Path(p) for p in args.store_paths]
            )

            if os.geteuid() != 0:
                show_paths_info(conn, validated_paths)
                sys.exit(0)
            else:
                if args.build_deps:
                    paths = get_runtime_and_build_deps(conn, validated_paths)
                else:
                    paths = get_runtime_deps(conn, validated_paths)

                count = touch_paths(conn, paths)
                print(f"Updated registration time for {count} store paths.")

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
