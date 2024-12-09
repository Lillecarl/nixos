#! /usr/bin/env python3

import os
import socket
import time
from pathlib import Path
from jinja2 import Environment, PackageLoader, select_autoescape


def main():
    env = Environment(
        loader=PackageLoader("niricfg", "templates"),
        autoescape=select_autoescape(),
        lstrip_blocks=True,
        trim_blocks=True,
    )

    while True:
        time.sleep(1)

        template = env.get_template("niricfg.j2")

        hostname = socket.gethostname()
        keyboard = "AT Translated Set 2 keyboard"
        if hostname == "shitbox":
            keyboard = "daskeyboard"

        info = {
            "hostname": socket.gethostname(),
            "keyboard": keyboard,
            "displays": [],
        }

        path = Path("~/.config/niri/config.kdl").expanduser()
        prev_conf = path.read_text()
        new_conf = template.render(info)
        if prev_conf == new_conf:
            print("No changes detected, waiting.")
        else:
            print("Writing new config.")
            path.write_text(new_conf)


if __name__ == "__main__":
    main()
