#!/bin/bash -e

ROOT_DIR=$(cd $(dirname "$0")/../; pwd)

# check if there are any changes to commit
if git diff-index --quiet HEAD --; then
  echo "no changes detected"
else
  echo "committing changes..."
  git -C "$ROOT_DIR" add .
  git -C "$ROOT_DIR" -c user.email="info@rook.io" -c user.name="Rook" commit --message="docs snapshot for rook version `$DOCS_VERSION`"
  echo "pushing changes..."
  git -C "$ROOT_DIR" push
fi
