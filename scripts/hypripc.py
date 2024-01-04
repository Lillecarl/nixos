#! /usr/bin/env python3

import os
import socket

instance_path = f"/tmp/hypr/{os.getenv('HYPRLAND_INSTANCE_SIGNATURE')}"
print(instance_path)
socket2_path = f"{instance_path}/.socket2.sock"
print(socket2_path)

socket2 = socket.socket(socket.AF_UNIX, socket.SOCK_STREAM)
print("Opening socket")
socket2.connect(socket2_path)

windows = {}


def handleLine(line):
    if line.startswith("openwindow"):
        line.replace("openwindow>>", "")
        args = line.split(",")
        windows[args[0]] = {}
    elif line.startswith("activewindow"):
        line.replace("activewindow>>", "")
        args = line.split(",")


if __name__ == "__main__":
    while True:
        line = socket.SocketIO(socket2, "r").readline().decode("utf-8")
        print(line)
        handleLine(line)
