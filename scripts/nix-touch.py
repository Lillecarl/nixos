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


def get_runtime_deps(conn: Connection, store_path: str) -> list[str]:
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

    return [row[0] for row in conn.execute(sql, (store_path,)).fetchall()]


def get_runtime_and_build_deps(conn: Connection, store_path: str) -> list[str]:
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

    return [row[0] for row in conn.execute(sql, (store_path,)).fetchall()]


def touch_paths(conn: Connection, paths: list[str]) -> int:
    """Update registration time for list of store paths"""

    if not paths:
        return 0

    sql = """
    UPDATE ValidPaths
    SET registrationTime = strftime('%s', 'now')
    WHERE path = ?;
    """

    with conn:
        conn.executemany(sql, [(path,) for path in paths])
    return len(paths)


def validate_store_path(conn: Connection, store_path: str) -> str:
    """Validate and resolve store path"""
    # Resolve symlinks like ./result
    if Path(store_path).is_symlink():
        resolved = Path(store_path).resolve()
        if str(resolved).startswith("/nix/store/"):
            store_path = str(resolved)

    if not store_path.startswith("/nix/store/"):
        raise Exception(f"Invalid store path: {store_path}")

    exists = conn.execute(
        "SELECT 1 FROM ValidPaths WHERE path = ?", (store_path,)
    ).fetchone()
    if not exists:
        raise Exception(f"Store path not found in database: {store_path}")

    return store_path


def show_path_info(conn: Connection, store_path: str):
    """Show information about store path"""
    result = conn.execute(
        """
        SELECT registrationTime
        FROM ValidPaths WHERE path = ?
    """,
        (store_path,),
    ).fetchone()

    if not result:
        print(f"No information found for {store_path}")
        return

    reg_time = result[0]
    import time

    reg_date = time.strftime("%Y-%m-%d %H:%M:%S", time.localtime(reg_time))

    print(f"Path: {store_path}")
    print(f"Registration time: {reg_date}")
    print(f"Runtime deps: {len(get_runtime_deps(conn, store_path))}")
    print(f"Buildtime deps: {len(get_runtime_and_build_deps(conn, store_path))}")


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
            db_uri = f"file:{db_path}?mode=ro&immutable=1"  # This could fail
        with sqlite3.connect(db_uri, uri=True) as conn:
            store_path = validate_store_path(conn, args.store_path)

            if args.info:
                show_path_info(conn, store_path)
                return

            if os.geteuid() != 0:
                print("Touching requires superpowers")
            else:
                if args.build_deps:
                    paths = get_runtime_and_build_deps(conn, store_path)
                else:
                    paths = get_runtime_deps(conn, store_path)

                count = touch_paths(conn, paths)
                print(f"Updated registration time for {count} store paths")

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
