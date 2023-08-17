#! /usr/bin/env python3

import argparse
import boto3
import json
import os
import random
import string

from datetime import datetime
from pathlib import Path
from plumbum import local, BG

grim = local["grim"]
slurp = local["slurp"]
swappy = local["swappy"]
hyprctl = local["hyprctl"]
wlcopy = local["wl-copy"]

parser = argparse.ArgumentParser()
parser.add_argument('mode')
parser.add_argument('--edit', action=argparse.BooleanOptionalAction)
parser.add_argument('--upload', action=argparse.BooleanOptionalAction)

args = parser.parse_args()

# Store prints in ~/Screens
basepath = Path("~/Screens/").expanduser()
# Create ~/Screens if it doesn't exist
basepath.mkdir(exist_ok=True)
filename= datetime.now().strftime('%Y%m%d-%H%M%S') + ".png"
filepath = os.path.join(basepath, filename)

pos = ""
# Get active window from hyprland
activewindow = json.loads(hyprctl(["activewindow", "-j"]))

if args.mode == "region":
  # Get coords to print with slurp (Rectangle overlay select)
  pos = slurp().strip()
elif args.mode == "window":
  # Get coords to print from activewindow
  windowloc = activewindow["at"]
  windowsize = activewindow["size"]
  pos = "{},{} {}x{}".format(windowloc[0], windowloc[1], windowsize[0], windowsize[1])
elif args.mode == "screen":
  # Get coords to print by checking which monitor activewindowbelongs to
  # then extract where monitor is located and how big it is
  monitorid = activewindow["monitor"]
  monitors = json.loads(hyprctl(["monitors", "-j"]))
  for i in monitors:
    if i["id"] == monitorid:
      pos = "{},{} {}x{}".format(i["x"], i["y"], i["width"], i["height"])

if args.edit:
  (grim["-g", pos, "-"] | swappy["-f", "-", "-o", filepath])()
else:
  grim(["-g", pos, filepath])

if args.upload:
  secrets = json.loads(Path("~/.local/hemlisar/s3_prints.json").expanduser().read_text())
  s3 = boto3.resource('s3', **secrets)
  bucket = s3.Bucket('prints') # type: ignore
  objectname = "{}_{}.png".format(filename.replace(".png", ""),
                         ''.join(random.choices(string.ascii_lowercase + string.digits, k=10)))

  bucket.upload_file(filepath, objectname) # type: ignore
  (wlcopy["-n", "https://prints.lillecarl.com/{}".format(objectname)] & BG) # type: ignore

