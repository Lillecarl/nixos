#! /usr/bin/env python3
import sqlite3
import subprocess
import logging
from argparse import ArgumentParser
from datetime import datetime, timedelta
from pathlib import Path

logger = logging.getLogger(__name__)


def get_dead_paths() -> list[str]:
    """Get list of dead store paths from nix-store."""
    result = subprocess.run(
        ["nix-store", "--gc", "--print-dead"],
        capture_output=True,
        text=True,
        check=True,
    )
    return [line.strip() for line in result.stdout.splitlines()]


def get_old_paths(
    dead_paths: list[str],
    days: int,
    db_path: Path = Path("/nix/var/nix/db/db.sqlite"),
) -> list[str]:
    """Filter dead paths to those older than specified days."""
    if not dead_paths:
        return []

    cutoff_time = int((datetime.now() - timedelta(days=days)).timestamp())

    with sqlite3.connect(db_path) as conn:
        cursor = conn.cursor()
        cursor.execute("CREATE TEMP TABLE DeadPaths (path TEXT PRIMARY KEY)")
        cursor.executemany(
            "INSERT INTO DeadPaths VALUES (?)", [(p,) for p in dead_paths]
        )

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
        logger.info("No paths to delete")
        return

    logger.info(f"{'Would delete' if dry_run else 'Deleting'} {len(paths)} paths")

    if dry_run:
        for path in paths:
            print(path)
        return

    subprocess.run(
        ["nix-store", "--delete", *paths],
        check=True,
        capture_output=True,
        text=True,
    )
    logger.info(f"Successfully deleted {len(paths)} paths")


def main() -> None:
    parser = ArgumentParser(description="Delete old dead Nix store paths")
    parser.add_argument("days", type=int, help="Delete paths older than this many days")
    parser.add_argument(
        "--dry-run", action="store_true", help="Print paths without deleting"
    )
    parser.add_argument(
        "--db-path",
        type=Path,
        default=Path("/nix/var/nix/db/db.sqlite"),
        help="Path to Nix database",
    )
    args = parser.parse_args()

    logging.basicConfig(level=logging.INFO, format="%(levelname)s: %(message)s")

    logger.info(f"Finding dead paths older than {args.days} days")

    dead_paths = get_dead_paths()
    logger.info(f"Found {len(dead_paths)} dead paths")

    old_paths = get_old_paths(dead_paths, args.days, args.db_path)
    logger.info(f"Found {len(old_paths)} paths older than {args.days} days")

    delete_paths(old_paths, args.dry_run)


if __name__ == "__main__":
    main()
