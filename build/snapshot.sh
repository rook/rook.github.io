#!/bin/bash -e

# build the container if not exists
if [[ "$(docker images -q rook.github.io 2> /dev/null)" == "" ]]; then
  echo "docker image `rook.github.io` does not exist... building..."
  docker build -f build/image/Dockerfile -t rook.github.io .
fi

# install node dependencies through container
echo "pulling npm dependencies..."
docker run --rm -v $(pwd):/opt/rook.github.io rook.github.io npm install

# run prepare script through container
echo "preparing static assets..."
docker run -t -v $(pwd):/opt/rook.github.io rook.github.io node build/scripts/prepare.js
