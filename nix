#! /usr/bin/env bash

nix --extra-experimental-features 'nix-command flakes repl-flake' $@
