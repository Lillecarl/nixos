#! /usr/bin/env/xonsh

import os
from pathlib import Path

for pstr in glob.glob("/sys/devices/virtual/input/*"):
try:
  root = Path(pstr)
  path = Path(os.path.join(root, "capabilities", "key"))
  if path.read_text().replace('\n', '') == "7fffffffffffff0f fff9ffffffffffff ffffffffffffffff fffffffffffffffe":
    for j in root.iterdir():
      if 'event' in str(j) and j.is_dir():
        eventpath = os.path.split(str(j))[1]
        print(eventpath)
        sudo tp-auto-kbbl -b 1 -t 2 -d /dev/input/@(eventpath)
except Exception as e: print(e)
