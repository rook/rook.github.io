#!/bin/bash -e

HOST_DIR=$(cd $(dirname "$0")/../; pwd)
CONTAINER_DIR="/opt/rook.github.io"

if [ -n "$HOST_USER" ]; then
  DOCKER_RUN="docker run -t --user $HOST_USER:$HOST_USER -w $CONTAINER_DIR -v $HOST_DIR:$CONTAINER_DIR node:8-alpine"
else
  DOCKER_RUN="docker run -t -w $CONTAINER_DIR -v $HOST_DIR:$CONTAINER_DIR node:8-alpine"
fi

# install node dependencies through container
echo "pulling npm dependencies..."
$DOCKER_RUN npm install

# run prepare script through container
echo "preprocessing static assets..."
$DOCKER_RUN node build/scripts/preprocess.js

echo "rook.github.io build complete"
