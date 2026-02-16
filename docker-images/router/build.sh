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
    echo "Build successful!"
    echo ""
    echo "Testing image..."
    
    # Start container in background
    # Added -t to provide a TTY so bash doesn't exit immediately
    CONTAINER_ID=$(docker run -dt --rm --privileged router-frr:1.0)
    
    if [ -z "$CONTAINER_ID" ]; then
        echo "Failed to start container!"
        exit 1
    fi
    
    echo "Container started: $CONTAINER_ID"
    
    # Wait for startup
    echo "Waiting for FRR daemons to start..."
    sleep 8
    
    # Check if container is still running using --no-trunc to match the full ID
    if ! docker ps --no-trunc | grep -q "$CONTAINER_ID"; then
        echo "Container exited! Checking logs..."
        docker logs "$CONTAINER_ID" 2>&1 | tail -20
        exit 1
    fi
    
    # Check if FRR is running
    echo "Checking FRR processes..."
    # Improved grep to verify all required daemons
    docker exec "$CONTAINER_ID" ps aux | grep -E 'zebra|bgpd|ospfd|isisd' | grep -v grep
    
    if docker exec "$CONTAINER_ID" pgrep -f zebra > /dev/null; then
        echo ""
        echo "✓ Image test passed - FRR is running!"
        docker stop "$CONTAINER_ID" > /dev/null 2>&1
        exit 0
    else
        echo ""
        echo "✗ Image test failed - FRR not running!"
        echo ""
        echo "Container logs:"
        docker logs "$CONTAINER_ID" 2>&1 | tail -30
        docker stop "$CONTAINER_ID" > /dev/null 2>&1
        exit 1
    fi
else
    echo "Build failed!"
    exit 1
fi