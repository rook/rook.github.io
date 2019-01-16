#!/bin/bash -e
# To support legacy method of publishing
# Can remove when either
# * 0.9 is no longer supported/updated
# * the rook makefile changes for this are backported to 0.9

ROOT_DIR=$(cd $(dirname "$0")/../; pwd)

cd "$ROOT_DIR"
make publish
