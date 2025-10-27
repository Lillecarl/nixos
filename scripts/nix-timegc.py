#!/usr/bin/env python3
import argparse
import sqlite3
import subprocess
import os
import sys
from sqlite3 import Connection
from datetime import datetime, timedelta
from pathlib import Path


def get_db_uri(db_path: Path) -> str:
    """Determines the correct SQLite connection URI based on user privileges."""
    if os.geteuid() == 0:
        return f"file:{db_path}?mode=rwc&immutable=0"
    else:
        # For non-root, first try a standard read-only connection.
        db_uri = f"file:{db_path}?mode=ro"
        try:
            # Test the connection to see if it works without immutable.
            # We need to run a query against a table to trigger wal and shm
            # creation if the user has write permissions in the directory.
            with sqlite3.connect(db_uri, uri=True) as testConn:
                testConn.execute("SELECT 1 FROM ValidPaths LIMIT 1;")
        except sqlite3.OperationalError:
            # If the above fails, it's likely due to permissions.
            # Fall back to an immutable connection which doesn't need to
            # create temporary files.
            db_uri = f"file:{db_path}?mode=ro&immutable=1"
        return db_uri


def get_dead_paths() -> list[str]:
    """Get list of dead store paths from nix-store."""
    print("Finding dead paths with 'nix-store --gc --print-dead'...")
    result = subprocess.run(
        ["nix-store", "--gc", "--print-dead"],
        capture_output=True,
        text=True,
        check=True,
    )
    return [line.strip() for line in result.stdout.splitlines()]


def get_old_paths(conn: Connection, dead_paths: list[str], seconds: int) -> list[str]:
    """Filter dead paths to those older than specified seconds."""
    if not dead_paths:
        return []

    cutoff_time = int((datetime.now() - timedelta(seconds=seconds)).timestamp())

    cursor = conn.cursor()
    # Use a temporary table for performance with large numbers of dead paths.
    cursor.execute("CREATE TEMP TABLE DeadPaths (path TEXT PRIMARY KEY)")
    cursor.executemany("INSERT INTO DeadPaths VALUES (?)", [(p,) for p in dead_paths])

    cursor.execute(
        """
        SELECT vp.path
        FROM ValidPaths vp
        INNER JOIN DeadPaths dp ON vp.path = dp.path
        WHERE vp.registrationTime < ?
        """,
        (cutoff_time,),
    )

    return [row[0] for row in cursor.fetchall()]


def delete_paths(paths: list[str], dry_run: bool = False) -> None:
    """Delete specified store paths."""
    if not paths:
        print("No old paths to delete.")
        return

    action = "Would delete" if dry_run else "Deleting"
    print(f"{action} {len(paths)} paths...")

    if dry_run:
        for path in paths:
            print(path)
        return

    # Use nix-store --delete for the actual deletion
    subprocess.run(
        ["nix-store", "--delete", *paths],
        check=True,
        capture_output=True,
        text=True,
    )
    print(f"Successfully deleted {len(paths)} paths.")


def main() -> None:
    parser = argparse.ArgumentParser(
        description="Delete dead Nix store paths older than a specified time.",
        formatter_class=argparse.RawDescriptionHelpFormatter,
    )
    parser.add_argument(
        "seconds", type=int, help="Delete paths older than this many seconds"
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="Print paths that would be deleted without deleting them.",
    )
    args = parser.parse_args()

    try:
        db_path = Path(os.environ.get("NIX_STATE_DIR", "/nix/var/nix")) / "db/db.sqlite"
        if not db_path.exists():
            raise Exception(f"Nix database not found: {db_path}")

        is_dry_run = args.dry_run or os.geteuid() != 0

        with sqlite3.connect(get_db_uri(db_path), uri=True) as conn:
            dead_paths = get_dead_paths()
            print(f"Found {len(dead_paths)} total dead paths.")

            old_paths = get_old_paths(conn, dead_paths, args.seconds)
            print(
                f"Found {len(old_paths)} dead paths older than {args.seconds} seconds."
            )

            delete_paths(old_paths, is_dry_run)

    except Exception as e:
        print(f"Error: {e}", file=sys.stderr)
        sys.exit(1)


if __name__ == "__main__":
    main()
