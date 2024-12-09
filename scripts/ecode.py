#! /usr/bin/env python3

import evdev
import json

keys = []

for i in evdev.ecodes.keys.items():
    if type(i[1]) is list:
        for j in i[1]:
            keys.append((i[0], j))
    else:
        keys.append((i[0], i[1]))

keys = sorted(keys, key=lambda x: x[0])


# print(r"class Keys(IntEnum):")
# for i in keys:
#    print(f"    {i[1]} = {i[0]}")

# for k,v in evdev._ecodes.__dict__.items():
#    if k.startswith("__"):
#        continue
#    print(k,v)

# for k,v in evdev.ecodes.bytype.items():
#    print(k,v)

for k, v in evdev._ecodes.__dict__.items():
    if not k.startswith("EV_"):
        continue
    print(k, v)
