#! /usr/bin/env python3

import kopf
import logging
import json
import sh
import asyncio
import time
import pykube
import threading
import signal
from queue import Queue
from typing import Any
from pathlib import Path
from pprint import pprint

from kubernetes_asyncio.client import api_client
from kubernetes_asyncio.client import CustomObjectsApi
from kubernetes_asyncio.client.configuration import Configuration
from kubernetes_asyncio.config import kube_config
from kubernetes_asyncio.dynamic import DynamicClient
from kubernetes_asyncio.dynamic.exceptions import ResourceNotFoundError

nix = sh.nix # type: ignore
cp = sh.cp # type: ignore
mkdir = sh.mkdir # type: ignore


aapi: api_client.ApiClient
pkConfig = pykube.KubeConfig.from_env()

class KnixExpr(pykube.objects.NamespacedAPIObject):
    version = "knix.cool/v1"
    endpoint = "expressions"
    kind = 'Expression'

taskqueue: Queue = Queue()
runpump: bool = True

# Idk how to do it any other way
async def pumptask():
    try:
        while runpump:
            await asyncio.sleep(1)
            while not taskqueue.empty():
                task: asyncio.Task[Any] = taskqueue.get()           
                await task
    except asyncio.CancelledError:
        pass

@kopf.on.startup() # type: ignore
async def on_startup(memo, settings: kopf.OperatorSettings, **_):
    # Global config variables is hot
    global aapi

    config = Configuration()
    await kube_config.load_kube_config(client_configuration=config)
    aapi = api_client.ApiClient(configuration=config)

    # Plain and simple local endpoint with an auto-generated certificate:
    # settings.admission.server = kopf.WebhookServer()
    settings.admission.managed = "knix.is.cool"
    settings.persistence.finalizer = "knix.is.cool/kopf-finalizer"
    memo["pumptask"] = asyncio.create_task(pumptask())
    for sig in (signal.SIGINT, signal.SIGTERM):
        asyncio.get_event_loop().add_signal_handler(
            sig, lambda: memo["pumptask"].cancel()
        )

@kopf.on.cleanup() # type: ignore
async def on_cleanup(memo, logger, **kwargs):
    global runpump
    runpump = False
    pass 

async def patch_cr_status(name, namespace, statusobject):
    client = CustomObjectsApi(api_client=aapi)
    await client.patch_namespaced_custom_object_status(
        name=name,
        namespace=namespace,
        group='knix.cool',
        version='v1',
        plural='expressions',
        body=[{
            "op": "replace",
            "path": "/status",
            "value": statusobject
        }]
    )

@kopf.on.mutate('expressions.knix.cool') # type: ignore
async def handle_expressions(name, namespace, body, memo, patch: kopf.Patch, warnings: list[str], **_):
    try:
        expr = body["data"]["expr"]
        print(expr)
        res = await nix("eval", "--impure", f"--expr", f"{expr}.outPath", _async=True, _return_cmd=True)
        if res.exit_code != 0:
            raise kopf.AdmissionError("""
Failed to evaluate nix expression
{expr}
stderr: {ex.stderr.decode()}
""")
    except Exception as ex:
        pass

    task = buildnix(
                   name=name,
                   namespace=namespace,
                   expr=body["data"]["expr"]
                   )
    taskqueue.put(task)

# This has to be mutate + create for some reason. Otherwise we get patch errors
@kopf.on.mutate('pods', operation="CREATE") # type: ignore
async def mutate_pods(body, patch, **_):
    try:
        exprObjName = body["metadata"]["annotations"]["knix-expr"]
        namespace = body["metadata"]["namespace"]
        knixExpr = await getKnixExpr(exprObjName, namespace)
    except KeyError as ex:
        return # keyerror just means we don't have the annotation

    packageBasePath = f"/nix/var/knix/{knixExpr["status"]["result"]}"

    existingVolumes = []
    try:
        existingVolumes = body["spec"]["volumes"]
    except:
        pass # No existing volumes

    existingVolumes.append({
                                "name": "knix",
                                "hostPath": {
                                    "path": str(packageBasePath),
                                    "type": "Directory",
                                }
                           })

    existingContainers = body["spec"]["containers"]
    for container in existingContainers:
        container["volumeMounts"].append({
                                          "mountPath": "/nix",
                                          "name": "knix",
                                      })

    patch["spec"] = {
        "volumes": existingVolumes,
        "containers": existingContainers
    }

async def buildnix(name, namespace, expr):
    await patch_cr_status(
                           name=name,
                           namespace=namespace,
                           statusobject = {
                               "phase": "Pending",
                               "message": "Evaluation successful, starting build",
                           })
    # Build nix expression
    nixBuild = await nix("build", "--print-out-paths", "--impure", "--expr", expr, _async=True,_return_cmd=True)
    if nixBuild.exit_code != 0:
        error = f"""
Failed to build nix expression:
{expr}
stderr:
{nixBuild.stderr.decode()}
"""
        raise kopf.AdmissionError(error)

    storePath = nixBuild.stdout.decode().splitlines()[0]
    storeName = Path(storePath).name
    packageBasePath = f"/nix/var/knix/{storeName}"

    # Get all paths and reflink copy them to a path that's mounted to both Nix container and host
    nixPathInfo = nix("path-info", "--recursive", "--impure", "--expr", expr, _return_cmd=True)
    if nixPathInfo.exit_code != 0:
        raise kopf.AdmissionError("nix path-info failed, this is weird")
    for path in nixPathInfo.stdout.decode().splitlines():
        # linkPath will become containers /nix
        pathMinusNix = path.removeprefix("/nix")
        linkPath = f"{packageBasePath}/{pathMinusNix}"
        mkdir("--parents", str(Path(linkPath).parent))
        cpout = cp("--recursive", "--reflink=always", "--archive", path, linkPath, _return_cmd=True)
        if cpout.exit_code != 0:
            logging.error(msg=f"Failed to copy {path} to {linkPath}")
            return

    await patch_cr_status(
                           name=name,
                           namespace=namespace,
                           statusobject = {
                               "phase": "Running",
                               "message": "Build finished",
                               "result": storeName,
                           })

# crName = custom resource name
async def getKnixExpr(crName, namespace):
    # client = CustomObjectsApi(api_client=aapi)
    client = await DynamicClient(aapi)
    resource = await client.resources.get(
                                          api_version="knix.cool/v1",
                                          kind="Expression",
                                          namespaced=True,
                                          
                                      )
    knixExpr = await resource.get(name=crName, namespace=namespace)
    return knixExpr
