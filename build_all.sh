#!/bin/bash

# BADASS Project - Build All Docker Images
# This script builds both host and router images

set -e  # Exit on error

echo "=========================================="
echo "BADASS Project - Building Docker Images"
echo "=========================================="
echo ""

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to print colored output
print_success() {
    echo -e "${GREEN}✓ $1${NC}"
}

print_error() {
    echo -e "${RED}✗ $1${NC}"
}

print_info() {
    echo -e "${YELLOW}→ $1${NC}"
}

# Check if Docker is installed
if ! command -v docker &> /dev/null; then
    print_error "Docker is not installed!"
    echo "Please install Docker first:"
    echo "  sudo apt install docker.io"
    echo "  sudo usermod -aG docker \$USER"
    exit 1
fi

# Check if user is in docker group
if ! groups | grep -q docker; then
    print_error "User is not in docker group!"
    echo "Run: sudo usermod -aG docker \$USER"
    echo "Then log out and log back in"
    exit 1
fi

# Build host image
print_info "Building host image..."
cd docker-images/host
bash build.sh
if [ $? -eq 0 ]; then
    print_success "Host image built successfully"
else
    print_error "Failed to build host image"
    exit 1
fi

cd ../..

# Build router image
print_info "Building router image..."
cd docker-images/router
bash build.sh
if [ $? -eq 0 ]; then
    print_success "Router image built successfully"
else
    print_error "Failed to build router image"
    exit 1
fi

cd ../..

echo ""
echo "=========================================="
echo "Build Summary"
echo "=========================================="
docker images | grep -E 'REPOSITORY|host-alpine|router-frr'

echo ""
print_success "All images built successfully!"
echo ""
echo "Next steps:"
echo "1. Open GNS3"
echo "2. Run: cd P1 && bash setup.sh"
echo "3. Follow the GNS3 configuration prompts"
echo ""

