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
    ;;
  *)
    echo "Error: Unrecognized workspace name: $WORKSPACE_NAME"
    exit 1
    ;;
esac

echo "Build complete - skipping workspace focus (Railway handles pruning)"
