#!/bin/bash
set -euo pipefail

cd /usr/local || { echo "Failed to cd to /usr/local"; exit 1; }

if [[ ! -f thor-lite-osx.zip ]]; then
  echo "thor-lite-osx.zip not found!"
  exit 1
fi

OUTPUT_DIR=$(mktemp -d)
unzip thor-lite-osx.zip -d thor-lite-osx
cd thor-lite-osx || { echo "Failed to cd to thor-lite-osx"; exit 1; }

chmod +x thor-lite-util thor-lite-macosx

./thor-lite-util upgrade -t thorlite-osx
./thor-lite-macosx --allreasons -e "$OUTPUT_DIR"

cd /usr/local

zip -r -X thor.zip "$OUTPUT_DIR"

rm -rf "$OUTPUT_DIR" thor-lite-osx