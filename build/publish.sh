#!/bin/bash -e

ROOT_DIR=$(cd $(dirname "$0")/../; pwd)

git -C "$ROOT_DIR" add -A

# check if there are any changes to commit
if git -C "$ROOT_DIR" diff-index --cached --quiet HEAD --; then
  echo "no changes detected"
else
  echo "committing changes..."
  git -C "$ROOT_DIR" -c user.email="info@rook.io" -c user.name="Rook" commit --message="docs snapshot for rook version `$DOCS_VERSION`"
  echo "pushing changes..."
  git -C "$ROOT_DIR" push
  echo "rook.github.io changes published"
fi
