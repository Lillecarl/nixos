#! /usr/bin/env python3

import json
from typing import List
from kitty.boss import Boss
from kitty.window import Window


def main():
    pass


from kittens.tui.handler import result_handler


@result_handler(no_ui=True)
def handle_result(
    args: List[str], answer: str, target_window_id: int, boss: Boss
) -> str:
    w: Window | None = boss.window_id_map.get(target_window_id)
    if w is not None:
        screen = w.screen
        cursor = screen.cursor
        return json.dumps(
            {
                "lines": w.screen.lines,
                "columns": w.screen.columns,
                "cursor": {
                    "x": cursor.x,
                    "y": cursor.y,
                    "height": screen.lines - cursor.y,
                },
            }
        )

    return "unk"
