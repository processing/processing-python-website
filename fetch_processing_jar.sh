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
wget -O processing.py-archive "$URL" && tar -xvzf processing.py-archive -C "$TARGET_DIR"

# Find the JAR file and rename it to processing-py.jar while moving it to the target directory
find "$TARGET_DIR" -name 'processing-py.jar' -exec mv {} "$TARGET_DIR/processing-py.jar" \;

# Now, make the libraries available
# Assuming the libraries are directly under the extracted "libraries/processing/" directory
LIB_DIR="$TARGET_DIR/libraries/processing/"

# Check if the libraries directory exists, then move it to the target directory
if [ -d "$LIB_DIR" ]; then
  echo "Moving Processing libraries to the target directory"
  # Move each library directory to the target directory
  # If you prefer them in a specific subdirectory, adjust the target path accordingly
  for lib in dxf io net opengl pdf serial video; do
    if [ -d "$LIB_DIR/$lib" ]; then
      mv "$LIB_DIR/$lib" "$TARGET_DIR/"
      echo "Moved $lib library"
    fi
  done
else
  echo "Libraries directory not found: $LIB_DIR"
fi

echo "Listing contents of $TARGET_DIR:"
ls -l "$TARGET_DIR"