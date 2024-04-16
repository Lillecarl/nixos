#! /usr/bin/env python3
c = c  # type: ignore
config = config # type: ignore

c.editor.command = ["kitty", "vim", "-f", "{file}", "-c", "normal {line}G{column0}l"]
c.tabs.position = "left"

config.bind("<ctrl-j>", "zoom-out")
config.bind("<ctrl-k>", "zoom-in")
