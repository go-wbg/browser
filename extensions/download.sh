#!/bin/bash
# Download and prepare WebExtensions for Firefox build
# This script reads extensions.json and downloads specified extensions

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_FILE="${SCRIPT_DIR}/extensions.json"
REPO_ROOT="$(dirname "${SCRIPT_DIR}")"

# Check if jq is installed
if ! command -v jq &> /dev/null; then
    echo "Error: jq is required but not installed."
    echo "Install with: sudo apt-get install jq"
    exit 1
fi

# Check if config file exists
if [ ! -f "$CONFIG_FILE" ]; then
    echo "Error: Configuration file not found: $CONFIG_FILE"
    exit 1
fi

# Read settings from JSON
CACHE_DIR="${REPO_ROOT}/$(jq -r '.settings.cache_directory' "$CONFIG_FILE")"
DIST_DIR="${REPO_ROOT}/$(jq -r '.settings.distribution_directory' "$CONFIG_FILE")"
VERIFY_SIG=$(jq -r '.settings.verify_signatures' "$CONFIG_FILE")

# Create directories if they don't exist
mkdir -p "$CACHE_DIR"
mkdir -p "$DIST_DIR"

# Clean distribution directory
echo "Cleaning distribution directory..."
rm -f "$DIST_DIR"/*.xpi

# Process each extension
echo "Processing extensions..."
jq -c '.extensions[]' "$CONFIG_FILE" | while read -r extension; do
    ENABLED=$(echo "$extension" | jq -r '.enabled')
    
    # Skip disabled extensions
    if [ "$ENABLED" != "true" ]; then
        echo "Skipping disabled extension: $(echo "$extension" | jq -r '.name')"
        continue
    fi
    
    ID=$(echo "$extension" | jq -r '.id')
    NAME=$(echo "$extension" | jq -r '.name')
    SOURCE=$(echo "$extension" | jq -r '.source')
    SHA256=$(echo "$extension" | jq -r '.sha256 // empty')
    
    FILENAME="${ID}.xpi"
    CACHE_PATH="${CACHE_DIR}/${FILENAME}"
    
    echo "Processing: $NAME"
    echo "  ID: $ID"
    echo "  Source: $SOURCE"
    
    # Download extension if not cached
    if [ ! -f "$CACHE_PATH" ]; then
        echo "  Downloading..."
        curl -L -o "$CACHE_PATH" "$SOURCE"
        
        # Verify SHA256 if provided
        if [ -n "$SHA256" ]; then
            echo "  Verifying SHA256..."
            echo "$SHA256  $CACHE_PATH" | sha256sum -c -
        fi
    else
        echo "  Using cached version"
    fi
    
    # Copy to distribution directory
    echo "  Copying to distribution directory..."
    cp "$CACHE_PATH" "$DIST_DIR/${FILENAME}"
    
    echo "  ✓ Done"
    echo ""
done

echo "Extension download complete!"
echo "Extensions placed in: $DIST_DIR"
