import sqlite3
import subprocess
import sys
import logging

logger = logging.getLogger(__name__)

def update_touch_time(package_path: str, db_path: str = "/nix/var/nix/db/db.sqlite"):
    # Get all paths including derivation and its closure
    try:
        result = subprocess.run(
            ["nix", "path-info", "--recursive", "--derivation", package_path],
            capture_output=True,
            text=True,
            check=True
        )
        output = result.stdout.strip()
    except subprocess.CalledProcessError as e:
        logger.error(f"Failed to get path info for {package_path}")
        logger.error(f"stderr: {e.stderr}")
        return

    # Filter out .drv files
    paths = [line for line in output.splitlines() if not line.endswith(".drv")]

    if not paths:
        logger.warning("No paths to update after filtering")
        return

    logger.info(f"Updating {len(paths)} paths")

    # Update database
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    try:
        cursor.execute("BEGIN IMMEDIATE")
        cursor.executemany(
            "UPDATE ValidPaths SET registrationTime = unixepoch() WHERE path = ?",
            [(path,) for path in paths]
        )
        conn.commit()

        updated_count = cursor.rowcount

        if updated_count != len(paths):
            logger.warning(f"Updated {updated_count} paths but expected {len(paths)}")
        else:
            logger.info(f"Updated {updated_count} paths")

    except Exception as e:
        conn.rollback()
        logger.error(f"Database update failed: {e}")
        raise
    finally:
        conn.close()

def main():
    if len(sys.argv) != 2:
        print("Usage: python touch_time.py /nix/store/...")
        sys.exit(1)

    logging.basicConfig(
        level=logging.INFO,
        format='%(levelname)s: %(message)s'
    )

    update_touch_time(sys.argv[1])

if __name__ == "__main__":
    main()

