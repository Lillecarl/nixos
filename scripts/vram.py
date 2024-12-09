#! /usr/bin/env python3

import subprocess
import json
import re
import psutil

from os import linesep
from plumbum import local

amdgpu_top = local["amdgpu_top"]["--json"]
hyprctl = local["hyprctl"]

process = amdgpu_top.popen(
    stdout=subprocess.PIPE,
    stderr=subprocess.PIPE,
    text=True,
    bufsize=0,
    universal_newlines=True,
)

error = False

while True:
    output_line = process.stdout.readline()  # type: ignore
    if output_line == "" and process.poll() is not None:
        break
    if output_line:
        data = json.loads(output_line)

        vram = data["VRAM"]
        used_vram = int(vram["Total VRAM Usage"]["value"])
        total_vram = int(vram["Total VRAM"]["value"])
        free_vram = total_vram - used_vram

        vram_usage_str = ""

        for k, v in data["fdinfo"].items():
            pattern = r"\((\d+)\)"  # Matches an integer inside parentheses
            match = re.search(r"\((\d+)\)", k)
            procname = k
            if match:
                if proc := psutil.Process(int(match.group(1))):
                    procname = proc.cmdline()[0]

            vram_usage_str += "{}VRAM: {}, cmd: {}".format(
                linesep, v["usage"]["VRAM"]["value"], procname
            )

        if free_vram < total_vram * 0.15:
            error = True
            print("Setting hyprctl error")
            hyprctl[
                "seterror",
                "rgba(FF0000FF)",
                "Free fram is running low, {}% used{}".format(
                    used_vram / total_vram, vram_usage_str
                ),
            ]()
        elif error:
            error = False
            print("Unsetting hyprctl error")
            hyprctl[
                "seterror",
                "disable",
            ]()
