#!/bin/bash
# Git Setup and Push Script for Linux/Mac
# This script initializes git repository and pushes code to remote

set -e  # Exit on error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

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

print_header() {
    echo ""
    echo -e "${CYAN}================================================${NC}"
    echo -e "${CYAN}$1${NC}"
    echo -e "${CYAN}================================================${NC}"
    echo ""
}

# Default values
REMOTE_URL=""
BRANCH="main"
INITIALIZE=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --remote-url)
            REMOTE_URL="$2"
            shift 2
            ;;
        --branch)
            BRANCH="$2"
            shift 2
            ;;
        --initialize)
            INITIALIZE=true
            shift
            ;;
        --help)
            print_info "Git Setup and Push Script"
            echo ""
            print_info "Usage: ./git-setup.sh [options]"
            echo ""
            echo "Options:"
            echo "  --remote-url URL    Remote repository URL (required for push)"
            echo "  --branch NAME       Branch name (default: main)"
            echo "  --initialize        Initialize git repository"
            echo "  --help              Show this help message"
            echo ""
            echo "Example:"
            echo "  ./git-setup.sh --remote-url 'https://github.com/user/repo.git' --initialize"
            echo "  ./git-setup.sh --remote-url 'https://github.com/user/repo.git' --branch 'main'"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_header "Git Setup and Push Script"

# Check if git is installed
if command -v git &> /dev/null; then
    GIT_VERSION=$(git --version)
    print_success "Git found: $GIT_VERSION"
else
    print_error "Git not found. Please install Git from https://git-scm.com"
    exit 1
fi

echo ""

# Step 1: Initialize git repository (if needed)
if [ "$INITIALIZE" = true ] || [ ! -d .git ]; then
    print_info "Step 1: Initializing git repository..."
    
    if [ -d .git ]; then
        print_info "Git repository already exists. Skipping initialization."
    else
        git init
        print_success "Git repository initialized"
    fi
    
    echo ""
fi

# Step 2: Check git status
print_info "Step 2: Checking git status..."

git status --short || print_warning "No changes found or git status check failed"

echo ""

# Step 3: Add all files
print_info "Step 3: Adding files to staging..."

git add .
print_success "Files added to staging"

echo ""

# Step 4: Check if there are changes to commit
if [ -z "$(git status --porcelain)" ]; then
    print_warning "No changes to commit"
else
    # Step 5: Commit changes
    print_info "Step 4: Committing changes..."
    
    if git log --oneline -1 > /dev/null 2>&1; then
        COMMIT_MESSAGE="Update: n8n SDLC integration files"
    else
        COMMIT_MESSAGE="Initial commit: n8n SDLC integration setup"
    fi
    
    git commit -m "$COMMIT_MESSAGE"
    print_success "Changes committed: $COMMIT_MESSAGE"
fi

echo ""

# Step 6: Set up remote and push (if URL provided)
if [ -n "$REMOTE_URL" ]; then
    print_info "Step 5: Setting up remote repository..."
    
    # Check if remote already exists
    if git remote get-url origin > /dev/null 2>&1; then
        REMOTE_EXISTS=$(git remote get-url origin)
        print_info "Remote 'origin' already exists: $REMOTE_EXISTS"
        read -p "Update remote URL? (y/n): " update_remote
        if [ "$update_remote" = "y" ] || [ "$update_remote" = "Y" ]; then
            git remote set-url origin "$REMOTE_URL"
            print_success "Remote URL updated"
        fi
    else
        git remote add origin "$REMOTE_URL"
        print_success "Remote 'origin' added: $REMOTE_URL"
    fi
    
    echo ""
    
    # Step 7: Push to remote
    print_info "Step 6: Pushing to remote repository..."
    print_info "Branch: $BRANCH"
    
    # Check if branch exists locally
    if git show-ref --verify --quiet refs/heads/$BRANCH; then
        # Switch to branch
        git checkout "$BRANCH"
        print_success "Switched to branch: $BRANCH"
    else
        # Create and switch to branch
        git checkout -b "$BRANCH"
        print_success "Created and switched to branch: $BRANCH"
    fi
    
    echo ""
    
    # Push to remote
    print_info "Pushing to origin/$BRANCH..."
    if git push -u origin "$BRANCH"; then
        print_success "Code pushed successfully to $REMOTE_URL"
    else
        print_warning "Push failed. You may need to:"
        print_info "  1. Check your remote URL"
        print_info "  2. Verify your authentication credentials"
        print_info "  3. Ensure you have push permissions"
        echo ""
        print_info "Try manually: git push -u origin $BRANCH"
    fi
else
    print_warning "No remote URL provided. Skipping push."
    echo ""
    print_info "To push your code later, use:"
    print_info "  git remote add origin <repository-url>"
    print_info "  git push -u origin $BRANCH"
fi

echo ""
print_header "Git setup completed!"

print_info "Next steps:"
print_info "1. Verify your remote: git remote -v"
print_info "2. Check your branch: git branch"
print_info "3. View commit history: git log --oneline"
echo ""
if [ -n "$REMOTE_URL" ]; then
    print_success "Your code is now available at: $REMOTE_URL"
else
    print_info "Add remote repository URL to push your code"
fi
echo ""

