#! /usr/bin/env python3

import asyncio
import os


class MiddleMan:
    send = None
    recv = None


class Hyprland(asyncio.Protocol):
    transport: asyncio.Transport
    mm: MiddleMan

    def __init__(self, data):
        self.mm = data
        self.mm.recv = self

    def write_data(self, data: str):
        self.transport.write(data.encode())

    def connection_made(self, transport):
        self.transport = transport  # type: ignore

    def data_received(self, data):
        message = data.decode()
        data1 = message.split(">>")
        func = data1[0]
        data = data1[1]
        if func == "activewindow":
            self.mm.send.write_data(data)

    def connection_lost(self, exc):
        print("Connection lost")


class Remapper(asyncio.Protocol):
    transport: asyncio.Transport
    mm: MiddleMan

    def __init__(self, data):
        self.mm = data
        self.mm.send = self

    def write_data(self, data: str):
        self.transport.write(data.encode())

    def connection_made(self, transport):
        self.transport = transport  # type: ignore

    def data_received(self, data):
        message = data.decode()

    def connection_lost(self, exc):
        print("Connection lost")


async def main():
    loop = asyncio.get_event_loop()

    middleman = MiddleMan()

    await loop.create_unix_connection(
        lambda: Remapper(middleman), path="/tmp/pykbd.sock"
    )
    hypr = await loop.create_unix_connection(
        lambda: Hyprland(middleman),
        path=f"/tmp/hypr/{os.environ['HYPRLAND_INSTANCE_SIGNATURE']}/.socket2.sock",
    )

    while True:
        await asyncio.sleep(1)


if __name__ == "__main__":
    asyncio.run(main())
