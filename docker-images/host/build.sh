#!/bin/bash

# Build script for host-alpine image

echo "Building host-alpine:1.0..."

# Build the image
docker build -t host-alpine:1.0 . 

if [ $? -eq 0 ]; then
    echo "Testing image..."
    # Quick test
    docker run --rm host-alpine:1.0 which ping > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        echo "Image test passed!"
        exit 0
    else
        echo "Image test failed!"
        exit 1
    fi
else
    echo "Build failed!"
    exit 1
fi
