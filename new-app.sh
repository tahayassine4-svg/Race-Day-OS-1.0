#!/bin/bash
# Usage: ./new-app.sh ~/projects/my-new-app
# Scaffolds a new project by copying this orchestration system to a new directory.

set -e

if [ -z "$1" ]; then
  echo "Usage: ./new-app.sh <target-directory>"
  echo "Example: ./new-app.sh ~/projects/my-new-app"
  exit 1
fi

TARGET="$1"

if [ -d "$TARGET" ]; then
  echo "Error: $TARGET already exists. Choose a different name."
  exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

cp -r "$SCRIPT_DIR" "$TARGET"

cd "$TARGET"

git init
git add .
git commit -m "init: orchestrated agent system scaffold"

echo ""
echo "✅ New app scaffolded at $TARGET"
echo ""
echo "Next steps:"
echo "  cd $TARGET"
echo "  claude"
echo ""
echo "Then describe your app idea and the Architect will take it from there."
