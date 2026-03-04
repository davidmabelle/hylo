#!/bin/bash

# Check if YARN2_WORKSPACE_PATH is set
if [ -z "$YARN2_WORKSPACE_PATH" ]; then
  echo "Error: YARN2_WORKSPACE_PATH is not set."
  exit 1
fi

WORKSPACE_NAME=$(basename "$YARN2_WORKSPACE_PATH")

case "$WORKSPACE_NAME" in
  "web")
    echo "Building $WORKSPACE_NAME"
    yarn workspace "$WORKSPACE_NAME" build
    ;;
  "backend")
    echo "Building @hylo/shared"
    yarn workspace @hylo/shared build

    echo "Building @hylo/navigation"
    yarn workspace @hylo/navigation build

    echo "Building @hylo/presenters"
    yarn workspace @hylo/presenters build

    # Remove vite cache created during builds above before focusing
    echo "Cleaning up locked caches..."
    find /app/apps -name ".vite" -type d -exec rm -rf {} + 2>/dev/null || true
    find /app/apps -name ".cache" -type d -exec rm -rf {} + 2>/dev/null || true
    ;;
  *)
    echo "Error: Unrecognized workspace name: $WORKSPACE_NAME"
    exit 1
    ;;
esac

if [ "$YARN2_SKIP_PRUNING" = "true" ]; then
  echo "Focusing on the $WORKSPACE_NAME workspace..."
  yarn workspaces focus "$WORKSPACE_NAME" --production
else
  echo "Warning: YARN2_SKIP_PRUNING is not set to true."
fi
