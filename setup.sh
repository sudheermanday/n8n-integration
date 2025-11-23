#!/bin/bash
# n8n SDLC Integration Setup Script for Linux/Mac
# This script automates the entire setup process

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
N8N_WEBHOOK_URL=""
GIT_PLATFORM_TOKEN=""
REPO_OWNER=""
REPO_NAME=""
GIT_PLATFORM="github"
SLACK_WEBHOOK_URL=""
SKIP_DOCKER=false
SKIP_WEBHOOK=false

# Parse arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --n8n-webhook-url)
            N8N_WEBHOOK_URL="$2"
            shift 2
            ;;
        --git-token)
            GIT_PLATFORM_TOKEN="$2"
            shift 2
            ;;
        --repo-owner)
            REPO_OWNER="$2"
            shift 2
            ;;
        --repo-name)
            REPO_NAME="$2"
            shift 2
            ;;
        --git-platform)
            GIT_PLATFORM="$2"
            shift 2
            ;;
        --slack-webhook)
            SLACK_WEBHOOK_URL="$2"
            shift 2
            ;;
        --skip-docker)
            SKIP_DOCKER=true
            shift
            ;;
        --skip-webhook)
            SKIP_WEBHOOK=true
            shift
            ;;
        --help)
            print_info "n8n SDLC Integration Setup Script"
            echo ""
            print_info "Usage: ./setup.sh [options]"
            echo ""
            echo "Options:"
            echo "  --n8n-webhook-url URL    Your n8n webhook URL (required)"
            echo "  --git-token TOKEN        Git platform token (required)"
            echo "  --repo-owner OWNER       Repository owner/organization (required)"
            echo "  --repo-name NAME         Repository name (required)"
            echo "  --git-platform PLATFORM  Git platform (github or gitlab, default: github)"
            echo "  --slack-webhook URL      Slack webhook URL (optional)"
            echo "  --skip-docker            Skip Docker setup"
            echo "  --skip-webhook           Skip webhook setup"
            echo "  --help                   Show this help message"
            echo ""
            echo "Example:"
            echo "  ./setup.sh --n8n-webhook-url 'http://localhost:5678' --git-token 'ghp_xxx' --repo-owner 'myorg' --repo-name 'myrepo'"
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

print_header "n8n SDLC Integration - Automated Setup"

# Check prerequisites
print_info "Checking prerequisites..."

# Check Node.js
if command -v node &> /dev/null; then
    NODE_VERSION=$(node --version)
    print_success "Node.js found: $NODE_VERSION"
else
    print_error "Node.js not found. Please install Node.js from https://nodejs.org"
    exit 1
fi

# Check npm
if command -v npm &> /dev/null; then
    NPM_VERSION=$(npm --version)
    print_success "npm found: $NPM_VERSION"
else
    print_error "npm not found. Please install npm"
    exit 1
fi

# Check Docker (optional)
DOCKER_AVAILABLE=false
if ! $SKIP_DOCKER && command -v docker &> /dev/null; then
    DOCKER_VERSION=$(docker --version)
    print_success "Docker found: $DOCKER_VERSION"
    DOCKER_AVAILABLE=true
elif ! $SKIP_DOCKER; then
    print_warning "Docker not found. Skipping Docker setup. (Install Docker to enable)"
    SKIP_DOCKER=true
fi

echo ""

# Gather required information
if [ -z "$N8N_WEBHOOK_URL" ]; then
    read -p "Enter your n8n webhook URL (e.g., http://localhost:5678): " N8N_WEBHOOK_URL
fi

if [ -z "$GIT_PLATFORM_TOKEN" ]; then
    read -sp "Enter your Git platform token: " GIT_PLATFORM_TOKEN
    echo ""
fi

if [ -z "$REPO_OWNER" ]; then
    read -p "Enter repository owner/organization: " REPO_OWNER
fi

if [ -z "$REPO_NAME" ]; then
    read -p "Enter repository name: " REPO_NAME
fi

if [ -z "$SLACK_WEBHOOK_URL" ]; then
    read -p "Enter Slack webhook URL (optional, press Enter to skip): " SLACK_WEBHOOK_URL
fi

echo ""

# Step 1: Install n8n
print_info "Step 1: Setting up n8n..."

if $DOCKER_AVAILABLE && ! $SKIP_DOCKER; then
    print_info "Installing n8n using Docker..."
    
    # Check if n8n container exists
    if docker ps -a --filter "name=n8n" --format "{{.Names}}" | grep -q "n8n"; then
        print_info "n8n container already exists. Starting it..."
        docker start n8n
    else
        print_info "Creating n8n container..."
        docker run -d \
            --name n8n \
            -p 5678:5678 \
            -v ~/.n8n:/home/node/.n8n \
            n8nio/n8n
    fi
    
    print_success "n8n is running in Docker container"
    print_info "Access n8n at: http://localhost:5678"
    print_info "Waiting for n8n to start..."
    sleep 10
else
    print_info "Installing n8n globally using npm..."
    if npm install -g n8n; then
        print_success "n8n installed successfully"
        print_info "Start n8n with: n8n start"
        print_warning "Make sure n8n is running before proceeding!"
        read -p "Is n8n running? (y/n): " continue
        if [ "$continue" != "y" ] && [ "$continue" != "Y" ]; then
            print_error "Please start n8n first and run this script again"
            exit 1
        fi
    else
        print_error "Failed to install n8n"
        exit 1
    fi
fi

echo ""

# Step 2: Install project dependencies
print_info "Step 2: Installing project dependencies..."

if [ -f "package.json" ]; then
    npm install
    print_success "Dependencies installed"
else
    print_warning "No package.json found. Skipping npm install..."
fi

echo ""

# Step 3: Create .env file
print_info "Step 3: Creating environment configuration..."

WEBHOOK_SECRET=$(uuidgen 2>/dev/null || cat /proc/sys/kernel/random/uuid 2>/dev/null || openssl rand -hex 16)

cat > .env <<EOF
# n8n SDLC Integration - Environment Variables
# Generated by setup script on $(date '+%Y-%m-%d %H:%M:%S')

# Git Platform Configuration
GIT_PLATFORM_TOKEN=$GIT_PLATFORM_TOKEN
GIT_PLATFORM=$GIT_PLATFORM
REPO_OWNER=$REPO_OWNER
REPO_NAME=$REPO_NAME

# n8n Configuration
N8N_WEBHOOK_URL=$N8N_WEBHOOK_URL
WEBHOOK_SECRET=$WEBHOOK_SECRET

# CI/CD Platform Configuration (configure as needed)
CI_PLATFORM_API_URL=
CI_PLATFORM_API_KEY=

# Communication Platforms
SLACK_WEBHOOK_URL=$SLACK_WEBHOOK_URL
MICROSOFT_TEAMS_WEBHOOK_URL=

# Issue Tracking (configure as needed)
JIRA_URL=
JIRA_EMAIL=
JIRA_API_TOKEN=
EOF

print_success "Created .env file"
echo ""

# Step 4: Import workflows
print_info "Step 4: Importing n8n workflows..."

WORKFLOW_FILES=(
    "workflows/feature-automation.json"
    "workflows/ci-cd-integration.json"
    "workflows/notifications.json"
    "workflows/code-quality.json"
)

IMPORTED_COUNT=0
for workflow_file in "${WORKFLOW_FILES[@]}"; do
    if [ -f "$workflow_file" ]; then
        print_info "Found workflow: $workflow_file"
        IMPORTED_COUNT=$((IMPORTED_COUNT + 1))
    else
        print_warning "Workflow file not found: $workflow_file"
    fi
done

print_info ""
print_info "To import workflows:"
print_info "1. Open n8n UI at $N8N_WEBHOOK_URL"
print_info "2. Go to 'Workflows' → 'Import from File'"
print_info "3. Import each file from the workflows/ directory"
print_info ""

# Step 5: Setup webhooks
print_info "Step 5: Setting up webhooks..."

if ! $SKIP_WEBHOOK; then
    print_info "Configuring webhook in Git platform..."
    
    export N8N_WEBHOOK_URL
    export GIT_PLATFORM_TOKEN
    export REPO_OWNER
    export REPO_NAME
    export GIT_PLATFORM
    
    if node scripts/setup-webhook.js create; then
        print_success "Webhook configured successfully"
    else
        print_warning "Webhook setup failed. You may need to configure it manually:"
        print_info "  - Go to your repository → Settings → Webhooks"
        print_info "  - Add webhook URL: $N8N_WEBHOOK_URL/webhook/git-webhook"
        print_info "  - Select events: Push, Pull request"
    fi
else
    print_info "Skipping webhook setup"
fi

echo ""

# Step 6: Test integration
print_info "Step 6: Testing integration..."

print_info "Creating test request..."

TEST_PAYLOAD=$(cat <<EOF
{
  "action": "create_feature",
  "repository": "$REPO_OWNER/$REPO_NAME",
  "feature_name": "test-feature",
  "ticket_id": "TEST-123",
  "feature_type": "api",
  "description": "Test feature created by setup script",
  "developer": "$(whoami)@company.com"
}
EOF
)

print_info "Test payload:"
echo "$TEST_PAYLOAD"
echo ""
print_info "To test, send POST request to: $N8N_WEBHOOK_URL/webhook/feature-request"
print_info "You can use the following curl command:"
echo ""
echo "curl -X POST '$N8N_WEBHOOK_URL/webhook/feature-request' \\"
echo "  -H 'Content-Type: application/json' \\"
echo "  -d '$TEST_PAYLOAD'"
echo ""

# Summary
print_header "Setup completed successfully!"

print_info "Next steps:"
print_info "1. Import workflows in n8n UI: $N8N_WEBHOOK_URL"
print_info "2. Configure credentials in n8n (GitHub, Slack, etc.)"
print_info "3. Test the integration with the test request above"
print_info "4. Review documentation: README.md, QUICKSTART.md"
echo ""
print_info "Workflows to import:"
for workflow_file in "${WORKFLOW_FILES[@]}"; do
    if [ -f "$workflow_file" ]; then
        print_info "  - $workflow_file"
    fi
done
echo ""
print_info "Configuration file: .env"
echo ""
print_success "Happy automating! 🚀"

