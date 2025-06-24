#!/bin/bash

set -e

MONITOR_DIR="$1"
cd "$MONITOR_DIR"

sleep 5 

# Add all changes, commit, and push to the repository
git add --all
if git diff-index --quiet HEAD --; then
  echo "No changes to commit"
else
  git commit -m "auto-commit:$(date '+%Y-%m-%d %H:%M:%S')"
  git push
fi
