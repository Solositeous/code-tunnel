#!/bin/bash
set -e

echo "Starting VS Code Tunnel..."

# Check if TUNNEL_NAME is set
if [ -z "$TUNNEL_NAME" ]; then
    echo "Error: TUNNEL_NAME environment variable is not set"
    exit 1
fi

# Start the tunnel
if [ -n "$GITHUB_TOKEN" ]; then
    echo "Authenticating with GitHub token..."
    echo "$GITHUB_TOKEN" | code tunnel --name "$TUNNEL_NAME" --accept-server-license-terms
else
    echo "Starting tunnel - you'll need to authenticate via browser..."
    code tunnel --name "$TUNNEL_NAME" --accept-server-license-terms
fi
