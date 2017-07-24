#!/bin/bash -e

HOST_DIR=$(cd $(dirname "$0")/../; pwd)
CONTAINER_DIR="/opt/rook.github.io"

# install node dependencies through container
echo "pulling npm dependencies..."
docker run --rm --user 1000 -w $CONTAINER_DIR -v $HOST_DIR:$CONTAINER_DIR node:8-alpine npm install

# run prepare script through container
echo "preparing static assets..."
docker run -t --user 1000 -w $CONTAINER_DIR -v $HOST_DIR:$CONTAINER_DIR node:8-alpine node build/scripts/preprocess.js
