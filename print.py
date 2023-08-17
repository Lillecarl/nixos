#! /usr/bin/env python3

import argparse
import base64
import json
import os
import requests

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
filename = os.path.join(basepath, datetime.now().strftime('%Y%m%d-%H%M%S') + ".png")

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
  (grim["-g", pos, "-"] | swappy["-f", "-", "-o", filename])()
else:
  grim(["-g", pos, filename])

if args.upload:
  apikey = "2a7e0bbdcf8777abafe2b05b531b11b3"
  img64 = base64.b64encode(Path(filename).read_bytes())

  params = {
      'expiration': '86400',
      'key': apikey,
  }

  files = {
      'image': (None, img64),
  }

  response = requests.post('https://api.imgbb.com/1/upload', params=params, files=files)
  url = response.json()["data"]["url"]
  (wlcopy["-n", url] & BG)
