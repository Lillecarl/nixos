#!/usr/bin/env python3
"""
nix-touch: Update Nix store path registration times for LRU garbage collection

This tool updates the registrationTime field in the Nix database for a store path
and its dependencies, effectively marking them as "recently used" for GC purposes.
"""

import argparse
import sqlite3
import sys
from pathlib import Path


class NixTouchError(Exception):
    """Base exception for nix-touch operations"""
    pass


def touch_runtime_deps(db_path: str, store_path: str, dry_run: bool = False) -> int:
    """Touch store path and runtime dependencies only"""

    base_query = """
    WITH RECURSIVE closure(id) AS (
        -- Start with the target store path
        SELECT id FROM ValidPaths WHERE path = ?

        UNION

        -- Recursively follow runtime dependencies
        SELECT r.reference
        FROM closure c
        JOIN Refs r ON c.id = r.referrer
    )"""

    if dry_run:
        sql = base_query + """
        SELECT COUNT(*) FROM ValidPaths
        WHERE id IN (SELECT DISTINCT id FROM closure);
        """
    else:
        sql = base_query + """
        UPDATE ValidPaths
        SET registrationTime = strftime('%s', 'now')
        WHERE id IN (SELECT DISTINCT id FROM closure);
        """

    with sqlite3.connect(db_path) as conn:
        if dry_run:
            return conn.execute(sql, (store_path,)).fetchone()[0]
        else:
            conn.execute(sql, (store_path,))
            return conn.execute("SELECT changes()").fetchone()[0]


def touch_with_build_deps(db_path: str, store_path: str, dry_run: bool = False) -> int:
    """Touch store path, runtime deps, and build dependencies"""

    base_query = """
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
    )"""

    if dry_run:
        sql = base_query + """
        SELECT COUNT(*) FROM ValidPaths
        WHERE id IN (SELECT DISTINCT id FROM closure);
        """
    else:
        sql = base_query + """
        UPDATE ValidPaths
        SET registrationTime = strftime('%s', 'now')
        WHERE id IN (SELECT DISTINCT id FROM closure);
        """

    with sqlite3.connect(db_path) as conn:
        if dry_run:
            return conn.execute(sql, (store_path,)).fetchone()[0]
        else:
            conn.execute(sql, (store_path,))
            return conn.execute("SELECT changes()").fetchone()[0]


def validate_store_path(db_path: str, store_path: str) -> str:
    """Validate and resolve store path"""
    # Resolve symlinks like ./result
    if Path(store_path).is_symlink():
        resolved = Path(store_path).resolve()
        if str(resolved).startswith('/nix/store/'):
            store_path = str(resolved)

    if not store_path.startswith('/nix/store/'):
        raise NixTouchError(f"Invalid store path: {store_path}")

    # Check if exists in database
    with sqlite3.connect(db_path) as conn:
        exists = conn.execute(
            "SELECT 1 FROM ValidPaths WHERE path = ?", (store_path,)
        ).fetchone()
        if not exists:
            raise NixTouchError(f"Store path not found in database: {store_path}")

    return store_path


def show_path_info(db_path: str, store_path: str):
    """Show information about store path"""
    with sqlite3.connect(db_path) as conn:
        result = conn.execute("""
            SELECT path, hash, registrationTime, deriver, narSize
            FROM ValidPaths WHERE path = ?
        """, (store_path,)).fetchone()

        if not result:
            print(f"No information found for {store_path}")
            return

        path, hash_val, reg_time, deriver, nar_size = result
        import time
        reg_date = time.strftime('%Y-%m-%d %H:%M:%S', time.localtime(reg_time))

        print(f"Store path: {path}")
        print(f"Hash: {hash_val}")
        print(f"Registration time: {reg_date}")
        print(f"Size: {nar_size} bytes" if nar_size else "Size: unknown")
        print(f"Deriver: {deriver}" if deriver else "Deriver: none")


def main():
    parser = argparse.ArgumentParser(
        description="Update Nix store path registration times for LRU garbage collection",
        epilog="""
Examples:
  %(prog)s /nix/store/abc123-hello-1.0          # Touch runtime dependencies
  %(prog)s ./result --build-deps                # Touch build + runtime deps
  %(prog)s /nix/store/xyz --dry-run            # Show what would be touched
  %(prog)s /nix/store/xyz --info               # Show path information
        """,
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    parser.add_argument('store_path', help='Nix store path to touch')
    parser.add_argument('--build-deps', action='store_true',
                       help='Also touch build-time dependencies')
    parser.add_argument('--dry-run', action='store_true',
                       help='Show count without making changes')
    parser.add_argument('--info', action='store_true',
                       help='Show path information and exit')
    parser.add_argument('--db-path', default='/nix/var/nix/db/db.sqlite',
                       help='Path to Nix database')
    parser.add_argument('--verbose', '-v', action='store_true',
                       help='Verbose output')

    args = parser.parse_args()

    try:
        if not Path(args.db_path).exists():
            raise NixTouchError(f"Nix database not found: {args.db_path}")

        store_path = validate_store_path(args.db_path, args.store_path)

        if args.info:
            show_path_info(args.db_path, store_path)
            return

        if args.verbose:
            mode = "runtime + build deps" if args.build_deps else "runtime deps only"
            print(f"Processing {store_path} ({mode})")

        if args.build_deps:
            count = touch_with_build_deps(args.db_path, store_path, args.dry_run)
        else:
            count = touch_runtime_deps(args.db_path, store_path, args.dry_run)

        action = "Would update" if args.dry_run else "Updated"
        print(f"{action} registration time for {count} store paths")

        if not args.dry_run and args.verbose:
            print("Use 'nix-collect-garbage --delete-older-than Xd' for LRU cleanup")

    except NixTouchError as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)
    except KeyboardInterrupt:
        print("\nAborted", file=sys.stderr)
        sys.exit(1)
    except Exception as e:
        print(f"Unexpected error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == '__main__':
    main()
