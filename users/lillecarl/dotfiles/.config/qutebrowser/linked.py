#! /usr/bin/env python3

c = c  # type: ignore
config = config # type: ignore

try:
    from qutebrowser.config.configfiles import ConfigAPI
    from qutebrowser.config.config import ConfigContainer
    config: ConfigAPI = config
    c: ConfigContainer = c
except:
    pass


c.editor.command = ["kitty", "vim", "-f", "{file}", "-c", "normal {line}G{column0}l"]
c.tabs.position = "left"

config.bind("<ctrl-j>", "zoom-out")
config.bind("<ctrl-k>", "zoom-in")
