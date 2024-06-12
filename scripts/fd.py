#! /usr/bin/env python3

import os

with os.fdopen(1, 'w') as fdfile:
    fdfile.write("written to fd 1\n")
    fdfile.close()
with os.fdopen(2, 'w') as fdfile:
    fdfile.write("written to fd 2\n")
    fdfile.close()
with os.fdopen(3, 'w') as fdfile:
    fdfile.write("written to fd 3\n")
    fdfile.close()
with os.fdopen(4, 'w') as fdfile:
    fdfile.write("written to fd 4\n")
    fdfile.close()
