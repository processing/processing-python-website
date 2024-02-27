#!/bin/bash

# Define the target directory from the first script argument, default to current directory if not provided
TARGET_DIR="${1:-.}"

# Define global constants for URLs
URL_LINUX64="https://py.processing.org/processing.py-linux64.tgz" 
URL_LINUX32="https://py.processing.org/processing.py-linux32.tgz"
URL_MAC="https://py.processing.org/processing.py-macosx.tgz"
URL_WINDOWS64="https://py.processing.org/processing.py-windows64.zip"
URL_WINDOWS32="https://py.processing.org/processing.py-windows32.zip"

# Detect the operating system
OS="unknown"
case "$(uname -s)" in
    Linux*)     OS="Linux";;
    Darwin*)    OS="Mac";;
    CYGWIN*|MINGW*|MSYS*) OS="Windows";;
    *)          OS="UNKNOWN";;
esac

# Detect the architecture
ARCH=$(uname -m)
URL=""

if [ "$OS" == "Linux" ]; then
    if [ "$ARCH" == "x86_64" ]; then
        URL="$URL_LINUX64"
    elif [ "$ARCH" == "i386" ] || [ "$ARCH" == "i686" ]; then
        URL="$URL_LINUX32"
    fi
elif [ "$OS" == "Mac" ]; then
    URL="$URL_MAC"
elif [ "$OS" == "Windows" ]; then
    # Assuming WSL for Windows
    if [ "$ARCH" == "x86_64" ]; then
        URL="$URL_WINDOWS64"
    else
        URL="$URL_WINDOWS32"
    fi
fi

if [ -z "$URL" ]; then
    echo "Unsupported OS or architecture: $OS $ARCH" >&2
    exit 1
fi

echo "Downloading Processing.py for $OS ($ARCH)"
wget -O processing.py-archive "$URL"

# Create a temporary directory for extraction
TEMP_DIR=$(mktemp -d)

# Extract the archive to the temporary directory
tar -xvzf processing.py-archive -C "$TEMP_DIR"

# Find the top level processing.py-* directory
TOP_LEVEL_DIR=$(find "$TEMP_DIR" -maxdepth 1 -type d -name 'processing.py-*' -print -quit)

if [ -n "$TOP_LEVEL_DIR" ]; then
    # Copy the processing-py.jar file to the target directory
    if [ -f "$TOP_LEVEL_DIR/processing-py.jar" ]; then
        cp "$TOP_LEVEL_DIR/processing-py.jar" "$TARGET_DIR/"
    fi

    # Copy the contents of the libraries directory to $TARGET_DIR/libraries/processing
    if [ -d "$TOP_LEVEL_DIR/libraries/processing" ]; then
        # Ensure the target libraries/processing directory exists
        mkdir -p "$TARGET_DIR/libraries/processing"
        cp -r "$TOP_LEVEL_DIR/libraries/processing/." "$TARGET_DIR/libraries/processing/"
    fi
else
    echo "The expected top level directory was not found in the archive."
fi

# Clean up: Remove the temporary directory
rm -rf "$TEMP_DIR"

echo "Listing contents of $TARGET_DIR/libraries/processing:"
ls -l "$TARGET_DIR/libraries/processing"