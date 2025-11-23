#!/bin/bash
# Docker Build Script for Linux/Mac
# Builds the custom n8n SDLC Integration Docker image

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m'

# Helper functions
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_info() {
    echo -e "${CYAN}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Default values
NO_CACHE=false
PUSH=false
TAG="latest"

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cache)
            NO_CACHE=true
            shift
            ;;
        --push)
            PUSH=true
            shift
            ;;
        --tag)
            TAG="$2"
            shift 2
            ;;
        --help)
            print_info "Docker Build Script for n8n SDLC Integration"
            echo ""
            print_info "Usage: ./docker-build.sh [options]"
            echo ""
            echo "Options:"
            echo "  --no-cache      Build without using cache"
            echo "  --push          Push image to registry after build"
            echo "  --tag TAG       Image tag (default: latest)"
            echo "  --help          Show this help message"
            echo ""
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_info "================================================"
print_info "Building n8n SDLC Integration Docker Image"
print_info "================================================"
echo ""

# Check if Docker is installed
if command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_success "Docker found: $DOCKER_VERSION"
else
    print_error "Docker not found. Please install Docker"
    exit 1
fi

# Check if Dockerfile exists
if [ ! -f "Dockerfile" ]; then
    print_error "Dockerfile not found!"
    exit 1
fi

echo ""
print_info "Image configuration:"
print_info "  Tag: n8n-sdlc-integration:$TAG"
print_info "  Context: . (current directory)"
echo ""

# Build command
BUILD_ARGS=("build" "-t" "n8n-sdlc-integration:$TAG" "-t" "n8n-sdlc-integration:latest")

if [ "$NO_CACHE" = true ]; then
    BUILD_ARGS+=("--no-cache")
    print_info "Building without cache..."
fi

BUILD_ARGS+=(".")

print_info "Starting build..."
print_info "Command: docker ${BUILD_ARGS[*]}"
echo ""

# Build image
if docker "${BUILD_ARGS[@]}"; then
    print_success "Image built successfully!"
    echo ""
    print_info "Image details:"
    docker images n8n-sdlc-integration:$TAG
    echo ""
    
    if [ "$PUSH" = true ]; then
        print_info "Pushing image to registry..."
        docker push "n8n-sdlc-integration:$TAG"
        docker push "n8n-sdlc-integration:latest"
        if [ $? -eq 0 ]; then
            print_success "Image pushed successfully!"
        else
            print_warning "Push failed. Make sure you're logged in to the registry."
        fi
    else
        print_info "To start the container:"
        print_info "  docker compose up -d"
        print_info "  OR"
        print_info "  ./docker-setup.sh --start"
    fi
else
    print_error "Build failed!"
    exit 1
fi

echo ""

