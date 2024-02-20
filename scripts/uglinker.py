#! /usr/bin/env python3

import json
import sys
import os
from plumbum import local

lnsf = local["ln"]["-s", "-f"]
unlink = local["unlink"]
ln = local["ln"]["-s", "-f"]


def readlink(args):
    try:
        return local["readlink"]["-f"](args)
    except Exception:
        return ""


def main():
    p1 = sys.argv[1]  # Previous generation links
    p2 = sys.argv[2]  # Current generation links

    verbose = os.getenv("VERBOSE") is not None

    prevgens = [p1]
    prevlinks = []

    newlinks = []
    try:
        newlinks = json.loads(local.path(p2).read())
    except Exception:
        print("No previous links found")

    tolink = newlinks
    tounlink = []

    # We'll handle multiple json files appended for previous generations
    for i in prevgens:
        try:
            prevlinks.extend(json.loads(local.path(i).read()))
        except Exception:
            print(f"Unable to read previous link state {i}")

    for oldlink in prevlinks:
        found = False
        for newlink in newlinks:
            if oldlink["dst"] == newlink["dst"]:
                found = True
                break
        if not found:
            tounlink.append(oldlink)
    for link in tounlink:
        try:
            if verbose or True:
                print("Unlinking {}", format(link["dst"]))
            local.path(link["dst"]).unlink()
        except Exception:
            pass

    for link in newlinks:
        dst = link["dst"]
        if readlink(link["dst"]) == readlink(link["src"]):
            continue  # Link already exists
        else:
            if verbose or True:
                print("Linking {} to {}".format(link["src"], link["dst"]))
            dst_parent = local.path(dst).dirname
            dst_parent.mkdir(mode=0o700)
            ln(["-s", "-f", link["src"], link["dst"]])

    if verbose:
        print("tolink")
        print(json.dumps(tolink, indent=4))
        print("toulink")
        print(json.dumps(tounlink, indent=4))

    return 0


if __name__ == "__main__":
    exit(main())
