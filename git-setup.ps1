# Git Setup and Push Script for Windows PowerShell
# This script initializes git repository and pushes code to remote

param(
    [string]$REMOTE_URL = "",
    [string]$BRANCH = "main",
    [switch]$Initialize = $false,
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
    Write-Info "Git Setup and Push Script"
    Write-Info ""
    Write-Info "Usage: .\git-setup.ps1 [options]"
    Write-Info ""
    Write-Info "Options:"
    Write-Info "  -REMOTE_URL URL    Remote repository URL (required for push)"
    Write-Info "  -BRANCH NAME       Branch name (default: main)"
    Write-Info "  -Initialize        Initialize git repository"
    Write-Info "  -Help              Show this help message"
    Write-Info ""
    Write-Info "Example:"
    Write-Info "  .\git-setup.ps1 -REMOTE_URL 'https://github.com/user/repo.git' -Initialize"
    Write-Info "  .\git-setup.ps1 -REMOTE_URL 'https://github.com/user/repo.git' -BRANCH 'main'"
    exit 0
}

Write-Info "================================================"
Write-Info "Git Setup and Push Script"
Write-Info "================================================"
Write-Info ""

# Check if git is installed
try {
    $gitVersion = git --version
    Write-Success "Git found: $gitVersion"
} catch {
    Write-Error "Git not found. Please install Git from https://git-scm.com"
    exit 1
}

Write-Info ""

# Step 1: Initialize git repository (if needed)
if ($Initialize -or -not (Test-Path .git)) {
    Write-Info "Step 1: Initializing git repository..."
    
    if (Test-Path .git) {
        Write-Info "Git repository already exists. Skipping initialization."
    } else {
        git init
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Git repository initialized"
        } else {
            Write-Error "Failed to initialize git repository"
            exit 1
        }
    }
    
    Write-Info ""
}

# Step 2: Check git status
Write-Info "Step 2: Checking git status..."

git status --short
if ($LASTEXITCODE -ne 0) {
    Write-Warning "Git status check failed or no changes found"
}

Write-Info ""

# Step 3: Add all files
Write-Info "Step 3: Adding files to staging..."

git add .
if ($LASTEXITCODE -eq 0) {
    Write-Success "Files added to staging"
} else {
    Write-Error "Failed to add files to staging"
    exit 1
}

Write-Info ""

# Step 4: Check if there are changes to commit
$statusOutput = git status --porcelain
if ([string]::IsNullOrWhiteSpace($statusOutput)) {
    Write-Warning "No changes to commit"
} else {
    # Step 5: Commit changes
    Write-Info "Step 4: Committing changes..."
    
    $commitMessage = "Initial commit: n8n SDLC integration setup"
    
    if ((git log --oneline -1 2>$null) -ne $null) {
        $commitMessage = "Update: n8n SDLC integration files"
    }
    
    git commit -m $commitMessage
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Changes committed: $commitMessage"
    } else {
        Write-Error "Failed to commit changes"
        exit 1
    }
}

Write-Info ""

# Step 6: Set up remote and push (if URL provided)
if ($REMOTE_URL) {
    Write-Info "Step 5: Setting up remote repository..."
    
    # Check if remote already exists
    $remoteExists = git remote get-url origin 2>$null
    if ($LASTEXITCODE -eq 0) {
        Write-Info "Remote 'origin' already exists: $remoteExists"
        $updateRemote = Read-Host "Update remote URL? (y/n)"
        if ($updateRemote -eq "y" -or $updateRemote -eq "Y") {
            git remote set-url origin $REMOTE_URL
            Write-Success "Remote URL updated"
        }
    } else {
        git remote add origin $REMOTE_URL
        if ($LASTEXITCODE -eq 0) {
            Write-Success "Remote 'origin' added: $REMOTE_URL"
        } else {
            Write-Error "Failed to add remote repository"
            exit 1
        }
    }
    
    Write-Info ""
    
    # Step 7: Push to remote
    Write-Info "Step 6: Pushing to remote repository..."
    Write-Info "Branch: $BRANCH"
    
    # Check if branch exists locally
    $branchExists = git show-ref --verify --quiet refs/heads/$BRANCH
    if ($LASTEXITCODE -ne 0) {
        # Create and switch to branch
        git checkout -b $BRANCH
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to create branch: $BRANCH"
            exit 1
        }
        Write-Success "Created and switched to branch: $BRANCH"
    } else {
        # Switch to branch
        git checkout $BRANCH
        if ($LASTEXITCODE -ne 0) {
            Write-Error "Failed to switch to branch: $BRANCH"
            exit 1
        }
        Write-Success "Switched to branch: $BRANCH"
    }
    
    Write-Info ""
    
    # Push to remote
    Write-Info "Pushing to origin/$BRANCH..."
    git push -u origin $BRANCH
    if ($LASTEXITCODE -eq 0) {
        Write-Success "Code pushed successfully to $REMOTE_URL"
    } else {
        Write-Warning "Push failed. You may need to:"
        Write-Info "  1. Check your remote URL"
        Write-Info "  2. Verify your authentication credentials"
        Write-Info "  3. Ensure you have push permissions"
        Write-Info ""
        Write-Info "Try manually: git push -u origin $BRANCH"
    }
} else {
    Write-Warning "No remote URL provided. Skipping push."
    Write-Info ""
    Write-Info "To push your code later, use:"
    Write-Info "  git remote add origin <repository-url>"
    Write-Info "  git push -u origin $BRANCH"
}

Write-Info ""
Write-Info "================================================"
Write-Success "Git setup completed!"
Write-Info "================================================"
Write-Info ""
Write-Info "Next steps:"
Write-Info "1. Verify your remote: git remote -v"
Write-Info "2. Check your branch: git branch"
Write-Info "3. View commit history: git log --oneline"
Write-Info ""
if ($REMOTE_URL) {
    Write-Success "Your code is now available at: $REMOTE_URL"
} else {
    Write-Info "Add remote repository URL to push your code"
}
Write-Info ""

