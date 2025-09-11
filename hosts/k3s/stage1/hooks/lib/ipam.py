#! /usr/bin/env python3

import os
import sys
import json
from pathlib import Path

contextPath = Path(os.environ["BINDING_CONTEXT_PATH"])
contextText = contextPath.read_text()
contextDict = json.loads(contextText)

services = list()

service = filter(
    lambda service: service["metadata"]["name"] == "nginx-ingress-nginx-controller"
    and service["metadata"]["namespace"] == "nginx",
    contextDict["service"],
)
print(list(service)[0])
