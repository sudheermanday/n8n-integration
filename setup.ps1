# n8n SDLC Integration Setup Script for Windows PowerShell
# This script automates the entire setup process

param(
    [string]$N8N_WEBHOOK_URL = "",
    [string]$GIT_PLATFORM_TOKEN = "",
    [string]$REPO_OWNER = "",
    [string]$REPO_NAME = "",
    [string]$GIT_PLATFORM = "github",
    [string]$SLACK_WEBHOOK_URL = "",
    [switch]$SkipDocker = $false,
    [switch]$SkipWebhook = $false,
    [switch]$Help = $false
)

$ErrorActionPreference = "Stop"

# Color output functions
function Write-ColorOutput($ForegroundColor) {
    $fc = $host.UI.RawUI.ForegroundColor
    $host.UI.RawUI.ForegroundColor = $ForegroundColor
    if ($args) {
        Write-Output $args
    }
    $host.UI.RawUI.ForegroundColor = $fc
}

function Write-Success { Write-ColorOutput Green "✅ $args" }
function Write-Info { Write-ColorOutput Cyan "ℹ️  $args" }
function Write-Warning { Write-ColorOutput Yellow "⚠️  $args" }
function Write-Error { Write-ColorOutput Red "❌ $args" }

# Show help
if ($Help) {
    Write-Info "n8n SDLC Integration Setup Script"
    Write-Info ""
    Write-Info "Usage: .\setup.ps1 [options]"
    Write-Info ""
    Write-Info "Options:"
    Write-Info "  -N8N_WEBHOOK_URL         Your n8n webhook URL (required)"
    Write-Info "  -GIT_PLATFORM_TOKEN      Git platform token (required)"
    Write-Info "  -REPO_OWNER              Repository owner/organization (required)"
    Write-Info "  -REPO_NAME               Repository name (required)"
    Write-Info "  -GIT_PLATFORM            Git platform (github or gitlab, default: github)"
    Write-Info "  -SLACK_WEBHOOK_URL       Slack webhook URL (optional)"
    Write-Info "  -SkipDocker              Skip Docker setup"
    Write-Info "  -SkipWebhook             Skip webhook setup"
    Write-Info "  -Help                    Show this help message"
    Write-Info ""
    Write-Info "Example:"
    Write-Info "  .\setup.ps1 -N8N_WEBHOOK_URL 'http://localhost:5678' -GIT_PLATFORM_TOKEN 'ghp_xxx' -REPO_OWNER 'myorg' -REPO_NAME 'myrepo'"
    exit 0
}

Write-Info "================================================"
Write-Info "n8n SDLC Integration - Automated Setup"
Write-Info "================================================"
Write-Info ""

# Check prerequisites
Write-Info "Checking prerequisites..."

# Check Node.js
try {
    $nodeVersion = node --version
    Write-Success "Node.js found: $nodeVersion"
} catch {
    Write-Error "Node.js not found. Please install Node.js from https://nodejs.org"
    exit 1
}

# Check npm
try {
    $npmVersion = npm --version
    Write-Success "npm found: $npmVersion"
} catch {
    Write-Error "npm not found. Please install npm"
    exit 1
}

# Check Docker (optional)
$dockerAvailable = $false
if (-not $SkipDocker) {
    try {
        $dockerVersion = docker --version
        Write-Success "Docker found: $dockerVersion"
        $dockerAvailable = $true
    } catch {
        Write-Warning "Docker not found. Skipping Docker setup. (Install Docker Desktop to enable)"
        $SkipDocker = $true
    }
}

Write-Info ""

# Gather required information
if (-not $N8N_WEBHOOK_URL) {
    $N8N_WEBHOOK_URL = Read-Host "Enter your n8n webhook URL (e.g., http://localhost:5678)"
}

if (-not $GIT_PLATFORM_TOKEN) {
    $GIT_PLATFORM_TOKEN = Read-Host "Enter your Git platform token" -AsSecureString
    $BSTR = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($GIT_PLATFORM_TOKEN)
    $GIT_PLATFORM_TOKEN = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($BSTR)
}

if (-not $REPO_OWNER) {
    $REPO_OWNER = Read-Host "Enter repository owner/organization"
}

if (-not $REPO_NAME) {
    $REPO_NAME = Read-Host "Enter repository name"
}

if (-not $SLACK_WEBHOOK_URL) {
    $slackInput = Read-Host "Enter Slack webhook URL (optional, press Enter to skip)"
    if ($slackInput) {
        $SLACK_WEBHOOK_URL = $slackInput
    }
}

Write-Info ""

# Step 1: Install n8n (if not using Docker)
Write-Info "Step 1: Setting up n8n..."

if ($dockerAvailable -and -not $SkipDocker) {
    Write-Info "Installing n8n using Docker..."
    
    # Check if n8n container exists
    $containerExists = docker ps -a --filter "name=n8n" --format "{{.Names}}" | Select-String -Pattern "n8n"
    
    if ($containerExists) {
        Write-Info "n8n container already exists. Starting it..."
        docker start n8n
    } else {
        Write-Info "Creating n8n container..."
        docker run -d `
            --name n8n `
            -p 5678:5678 `
            -v "${env:USERPROFILE}\.n8n:/home/node/.n8n" `
            n8nio/n8n
    }
    
    Write-Success "n8n is running in Docker container"
    Write-Info "Access n8n at: http://localhost:5678"
    Write-Info "Waiting for n8n to start..."
    Start-Sleep -Seconds 10
} else {
    Write-Info "Installing n8n globally using npm..."
    try {
        npm install -g n8n
        Write-Success "n8n installed successfully"
        Write-Info "Start n8n with: n8n start"
        Write-Warning "Make sure n8n is running before proceeding!"
        $continue = Read-Host "Is n8n running? (y/n)"
        if ($continue -ne "y" -and $continue -ne "Y") {
            Write-Error "Please start n8n first and run this script again"
            exit 1
        }
    } catch {
        Write-Error "Failed to install n8n: $_"
        exit 1
    }
}

Write-Info ""

# Step 2: Install project dependencies
Write-Info "Step 2: Installing project dependencies..."

try {
    npm install
    Write-Success "Dependencies installed"
} catch {
    Write-Warning "No package.json found or npm install failed. Continuing..."
}

Write-Info ""

# Step 3: Create .env file
Write-Info "Step 3: Creating environment configuration..."

$envContent = @"
# n8n SDLC Integration - Environment Variables
# Generated by setup script on $(Get-Date -Format "yyyy-MM-dd HH:mm:ss")

# Git Platform Configuration
GIT_PLATFORM_TOKEN=$GIT_PLATFORM_TOKEN
GIT_PLATFORM=$GIT_PLATFORM
REPO_OWNER=$REPO_OWNER
REPO_NAME=$REPO_NAME

# n8n Configuration
N8N_WEBHOOK_URL=$N8N_WEBHOOK_URL
WEBHOOK_SECRET=$(New-Guid)

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
"@

$envContent | Out-File -FilePath ".env" -Encoding UTF8
Write-Success "Created .env file"
Write-Info ""

# Step 4: Import workflows
Write-Info "Step 4: Importing n8n workflows..."

$workflowFiles = @(
    "workflows/feature-automation.json",
    "workflows/ci-cd-integration.json",
    "workflows/notifications.json",
    "workflows/code-quality.json"
)

$importedCount = 0
foreach ($workflowFile in $workflowFiles) {
    if (Test-Path $workflowFile) {
        Write-Info "Importing $workflowFile..."
        Write-Warning "Manual import required: Go to n8n UI → Workflows → Import from File → Select $workflowFile"
        $importedCount++
    } else {
        Write-Warning "Workflow file not found: $workflowFile"
    }
}

Write-Info ""
Write-Info "To import workflows:"
Write-Info "1. Open n8n UI at $N8N_WEBHOOK_URL"
Write-Info "2. Go to 'Workflows' → 'Import from File'"
Write-Info "3. Import each file from the workflows/ directory"
Write-Info ""

# Step 5: Setup webhooks
Write-Info "Step 5: Setting up webhooks..."

if (-not $SkipWebhook) {
    Write-Info "Configuring webhook in Git platform..."
    
    $env:N8N_WEBHOOK_URL = $N8N_WEBHOOK_URL
    $env:GIT_PLATFORM_TOKEN = $GIT_PLATFORM_TOKEN
    $env:REPO_OWNER = $REPO_OWNER
    $env:REPO_NAME = $REPO_NAME
    $env:GIT_PLATFORM = $GIT_PLATFORM
    
    try {
        node scripts/setup-webhook.js create
        Write-Success "Webhook configured successfully"
    } catch {
        Write-Warning "Webhook setup failed. You may need to configure it manually:"
        Write-Info "  - Go to your repository → Settings → Webhooks"
        Write-Info "  - Add webhook URL: $N8N_WEBHOOK_URL/webhook/git-webhook"
        Write-Info "  - Select events: Push, Pull request"
    }
} else {
    Write-Info "Skipping webhook setup"
}

Write-Info ""

# Step 6: Test integration
Write-Info "Step 6: Testing integration..."

Write-Info "Creating test request..."
$testPayload = @{
    action = "create_feature"
    repository = "$REPO_OWNER/$REPO_NAME"
    feature_name = "test-feature"
    ticket_id = "TEST-123"
    feature_type = "api"
    description = "Test feature created by setup script"
    developer = "$env:USERNAME@company.com"
} | ConvertTo-Json

Write-Info "Test payload:"
Write-Info $testPayload
Write-Info ""
Write-Info "To test, send POST request to: $N8N_WEBHOOK_URL/webhook/feature-request"
Write-Info "You can use the following curl command (adjust for PowerShell):"
Write-Info "Invoke-RestMethod -Uri '$N8N_WEBHOOK_URL/webhook/feature-request' -Method Post -Body '$testPayload' -ContentType 'application/json'"

Write-Info ""

# Summary
Write-Info "================================================"
Write-Success "Setup completed successfully!"
Write-Info "================================================"
Write-Info ""
Write-Info "Next steps:"
Write-Info "1. Import workflows in n8n UI: $N8N_WEBHOOK_URL"
Write-Info "2. Configure credentials in n8n (GitHub, Slack, etc.)"
Write-Info "3. Test the integration with the test request above"
Write-Info "4. Review documentation: README.md, QUICKSTART.md"
Write-Info ""
Write-Info "Workflows to import:"
foreach ($workflowFile in $workflowFiles) {
    if (Test-Path $workflowFile) {
        Write-Info "  - $workflowFile"
    }
}
Write-Info ""
Write-Info "Configuration file: .env"
Write-Info ""
Write-Success "Happy automating! 🚀"

