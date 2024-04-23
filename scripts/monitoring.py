# ! /usr/bin/env python3

import sqlite3
import psutil
import time
import json

from plumbum import local

sensors = local["sensors"]["-j"]
rdmsr = local["rdmsr"]
readwatt = rdmsr["-p", "0", "0xC001029B", "-d"]


def create_connection(db_file):
    """create a database connection to the SQLite database
        specified by db_file
    :param db_file: database file
    :return: Connection object or None
    """
    conn = None
    try:
        conn = sqlite3.connect(db_file)
        return conn
    except sqlite3.Error as e:
        print(e)

    return conn


def get_energy_unit():
    data = int(rdmsr("-p", "0", "0xC0010299", "-d"))

    return float(pow(1.0 / 2.0, float((data >> 8) & 0x1F)))


def createtable(conn, tablename):
    conn.execute(f"""CREATE TABLE IF NOT EXISTS
                 {tablename}(
                    time INTEGER PRIMARY KEY,
                    value REAL
                 )
                 STRICT;""")


def createtables(conn):
    createtable(conn, "batpct")
    createtable(conn, "cpu")
    createtable(conn, "cpu_power")
    createtable(conn, "fan")
    createtable(conn, "power")
    createtable(conn, "temp")

    conn.commit()


def insertmetric(conn, table, value):
    ctime: int = int(time.time())
    conn.execute(
        f"""INSERT INTO
                        {table}
                        (
                            time,
                            value
                        )
                        VALUES
                        (
                            ?,
                            ?
                        )""",
        (ctime, value),
    )


def main():
    conn = create_connection("/var/lib/grafana/data/monitoring.sqlite3")

    if not conn:
        return

    conn.execute("pragma journal_mode=wal")
    conn.commit()

    conn.execute("VACUUM")
    conn.commit()

    createtables(conn)

    batpath = local.path("/sys/class/power_supply/BAT0/")

    owatt = float(readwatt())
    otime = time.time()

    energy_unit = get_energy_unit()

    while True:
        time.sleep(1)

        nwatt = float(readwatt())
        ntime = time.time()

        dtime = ntime - otime

        cpu_power = ((nwatt - owatt) / dtime) * energy_unit

        data = json.loads(sensors())

        cpu_pct: float = float(psutil.cpu_percent(interval=1))
        fan_speed: float = float(data["thinkpad-isa-0000"]["fan1"]["fan1_input"])
        cpu_temp: float = float(data["thinkpad-isa-0000"]["CPU"]["temp1_input"])
        charging: bool = "Charging" in (batpath / "status").read()
        power_now: float = float((batpath / "power_now").read()) / 1000000
        current_charge: float = float((batpath / "capacity").read().rstrip())

        if not charging:
            power_now = -power_now

        print(f"cpu_pct: {cpu_pct}")
        print(f"fan_speed: {fan_speed}")
        print(f"cpu_temp: {cpu_temp}")
        print(f"power_now: {power_now}")
        print(f"cpu_power: {cpu_power}")
        print(f"current_charge: {current_charge}")

        print(f"dtime: {dtime}")

        insertmetric(conn, "batpct", float(current_charge))
        insertmetric(conn, "cpu", cpu_pct)
        insertmetric(conn, "cpu_power", cpu_power)
        insertmetric(conn, "fan", float(fan_speed))
        insertmetric(conn, "power", float(power_now))
        insertmetric(conn, "temp", float(cpu_temp))

        conn.commit()

        # Set old values to new for next iteration
        owatt = nwatt
        otime = ntime


if __name__ == "__main__":
    main()
