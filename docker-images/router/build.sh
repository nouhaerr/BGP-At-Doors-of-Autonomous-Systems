#!/bin/bash

# Build script for router-frr image

echo "Building router-frr:1.0..."

# Ensure start.sh exists
if [ ! -f start.sh ]; then
    echo "Error: start.sh not found!"
    exit 1
fi

# Build the image
docker build -t router-frr:1.0 .

if [ $? -eq 0 ]; then
    echo "Testing image..."
    # Start container in background
    CONTAINER_ID=$(docker run -d --rm --privileged router-frr:1.0)
    
    # Wait for startup
    sleep 5
    
    # Check if FRR is running
    docker exec $CONTAINER_ID ps aux | grep -q zebra
    if [ $? -eq 0 ]; then
        echo "Image test passed!"
        docker stop $CONTAINER_ID > /dev/null 2>&1
        exit 0
    else
        echo "Image test failed - FRR not running!"
        docker stop $CONTAINER_ID > /dev/null 2>&1
        exit 1
    fi
else
    echo "Build failed!"
    exit 1
fi
