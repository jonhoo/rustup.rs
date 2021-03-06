#!/bin/bash

set -u -e

# Not every build sets EXE_EXT since it is empty for non .exe builds
# So this sets it explicitly to the empty string if it's unset.
EXE_EXT=${EXE_EXT:=}

if [ "$TRAVIS_PULL_REQUEST" = "true" ] || [ "$TRAVIS_BRANCH" = "auto" ]; then
    exit 0
fi

# Copy rustup-init to rustup-setup for backwards compatibility
cp target/"$TARGET"/release/rustup-init"${EXE_EXT}" target/"$TARGET"/release/rustup-setup"${EXE_EXT}"

# Generate hashes
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
    find target/"$TARGET"/release/ -maxdepth 1 -type f -exec sh -c 'fn="$1"; shasum -a 256 -b "$fn" > "$fn".sha256' sh {} \;
else
    find target/"$TARGET"/release/ -maxdepth 1 -type f -exec sh -c 'fn="$1"; sha256sum -b "$fn" > "$fn".sha256' sh {} \;
fi

# The directory for deployment artifacts
dest="deploy"

# Prepare bins for upload
bindest="$dest/dist/$TARGET"
mkdir -p "$bindest/"
cp target/"$TARGET"/release/rustup-init"${EXE_EXT}" "$bindest/"
cp target/"$TARGET"/release/rustup-init"${EXE_EXT}".sha256 "$bindest/"
cp target/"$TARGET"/release/rustup-setup"${EXE_EXT}" "$bindest/"
cp target/"$TARGET"/release/rustup-setup"${EXE_EXT}".sha256 "$bindest/"

if [ "$TARGET" != "x86_64-unknown-linux-gnu" ]; then
    exit 0
fi

cp rustup-init.sh "$dest/"

# Prepare website for upload
cp -R www "$dest/www"
