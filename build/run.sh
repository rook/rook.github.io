#!/bin/bash -e

cd "$( dirname "${BASH_SOURCE[0]}" )/../" || { echo "Can't enter build/ directory."; exit 1; }

./build/build.sh

docker run -it -v "$(pwd)":/srv/jekyll jekyll/jekyll jekyll build --watch
