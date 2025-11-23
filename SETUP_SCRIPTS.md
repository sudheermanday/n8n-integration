# Setup Scripts Guide

This directory contains automated setup scripts for different operating systems to help you quickly set up the n8n SDLC integration.

## Available Scripts

### Windows PowerShell (Recommended for Windows)
**File**: `setup.ps1`

**Usage**:
```powershell
.\setup.ps1 [options]
```

**Example**:
```powershell
.\setup.ps1 `
  -N8N_WEBHOOK_URL "http://localhost:5678" `
  -GIT_PLATFORM_TOKEN "ghp_your_token" `
  -REPO_OWNER "myorg" `
  -REPO_NAME "myrepo" `
  -SLACK_WEBHOOK_URL "https://hooks.slack.com/services/YOUR/WEBHOOK"
```

**Interactive Mode** (prompts for values):
```powershell
.\setup.ps1
```

**Help**:
```powershell
.\setup.ps1 -Help
```

### Linux/Mac Bash
**File**: `setup.sh`

**Make executable**:
```bash
chmod +x setup.sh
```

**Usage**:
```bash
./setup.sh [options]
```

**Example**:
```bash
./setup.sh \
  --n8n-webhook-url "http://localhost:5678" \
  --git-token "ghp_your_token" \
  --repo-owner "myorg" \
  --repo-name "myrepo" \
  --slack-webhook "https://hooks.slack.com/services/YOUR/WEBHOOK"
```

**Interactive Mode** (prompts for values):
```bash
./setup.sh
```

**Help**:
```bash
./setup.sh --help
```

### Windows CMD
**File**: `setup.bat`

**Usage**:
```cmd
setup.bat
```

**Note**: This script runs in interactive mode and will prompt for all required values.

## What the Scripts Do

The setup scripts automate the following steps:

1. **Prerequisites Check**
   - Verifies Node.js and npm are installed
   - Checks for Docker (optional)

2. **n8n Installation**
   - Option 1: Sets up n8n in Docker container
   - Option 2: Installs n8n globally via npm

3. **Project Setup**
   - Installs project dependencies (if package.json exists)
   - Creates `.env` file with configuration

4. **Workflow Import Instructions**
   - Provides instructions for importing n8n workflows

5. **Webhook Configuration**
   - Automatically configures webhooks in Git platform (GitHub/GitLab)

6. **Testing**
   - Provides test commands to verify the integration

## Required Parameters

### Minimum Required
- `N8N_WEBHOOK_URL` - Your n8n instance URL (e.g., `http://localhost:5678`)
- `GIT_PLATFORM_TOKEN` - Your Git platform access token
- `REPO_OWNER` - Repository owner/organization name
- `REPO_NAME` - Repository name

### Optional Parameters
- `GIT_PLATFORM` - Git platform (`github` or `gitlab`, default: `github`)
- `SLACK_WEBHOOK_URL` - Slack webhook URL for notifications
- `SKIP_DOCKER` - Skip Docker setup (use npm installation instead)
- `SKIP_WEBHOOK` - Skip automatic webhook configuration

## Quick Start

### Windows (PowerShell)

1. **Open PowerShell** in the project directory

2. **Run the script**:
   ```powershell
   .\setup.ps1
   ```

3. **Follow the prompts** to enter your configuration values

4. **Complete the setup** by importing workflows in n8n UI

### Linux/Mac

1. **Make the script executable**:
   ```bash
   chmod +x setup.sh
   ```

2. **Run the script**:
   ```bash
   ./setup.sh
   ```

3. **Follow the prompts** to enter your configuration values

4. **Complete the setup** by importing workflows in n8n UI

### Windows (CMD)

1. **Open Command Prompt** in the project directory

2. **Run the script**:
   ```cmd
   setup.bat
   ```

3. **Follow the prompts** to enter your configuration values

4. **Complete the setup** by importing workflows in n8n UI

## Detailed Steps

### Step 1: Prerequisites

The script checks for:
- ✅ Node.js (required)
- ✅ npm (required)
- ✅ Docker (optional, for containerized n8n)

If any required tools are missing, the script will provide installation instructions.

### Step 2: n8n Installation

**Docker Method** (recommended if Docker is available):
- Creates or starts n8n Docker container
- Maps port 5678 for web access
- Persists data in `~/.n8n` directory

**npm Method** (if Docker not available):
- Installs n8n globally using npm
- Prompts you to start n8n before proceeding
- Start n8n with: `n8n start`

### Step 3: Environment Configuration

The script creates a `.env` file with:
- Git platform credentials
- n8n webhook URL
- Repository information
- Optional integration settings (Slack, JIRA, etc.)

**Important**: The `.env` file is created but not committed to Git (it's in `.gitignore`)

### Step 4: Workflow Import

The script provides instructions for importing workflows. You need to:
1. Open n8n UI (usually `http://localhost:5678`)
2. Navigate to **Workflows** → **Import from File**
3. Import each workflow from the `workflows/` directory:
   - `feature-automation.json`
   - `ci-cd-integration.json`
   - `notifications.json`
   - `code-quality.json`

### Step 5: Webhook Setup

The script attempts to automatically configure webhooks in your Git platform.

**Manual Setup** (if automatic setup fails):
1. Go to your repository → **Settings** → **Webhooks**
2. Click **Add webhook**
3. Set Payload URL: `{N8N_WEBHOOK_URL}/webhook/git-webhook`
4. Content type: `application/json`
5. Select events: **Push**, **Pull request**
6. Add webhook secret (optional)
7. Click **Add webhook**

### Step 6: Testing

The script provides a test command you can use to verify the integration:

**Windows PowerShell**:
```powershell
Invoke-RestMethod -Uri 'http://localhost:5678/webhook/feature-request' `
  -Method Post `
  -Body (@{
    action = "create_feature"
    repository = "myorg/myrepo"
    feature_name = "test-feature"
    ticket_id = "TEST-123"
    feature_type = "api"
    description = "Test feature"
    developer = "developer@company.com"
  } | ConvertTo-Json) `
  -ContentType 'application/json'
```

**Linux/Mac**:
```bash
curl -X POST 'http://localhost:5678/webhook/feature-request' \
  -H 'Content-Type: application/json' \
  -d '{
    "action": "create_feature",
    "repository": "myorg/myrepo",
    "feature_name": "test-feature",
    "ticket_id": "TEST-123",
    "feature_type": "api",
    "description": "Test feature",
    "developer": "developer@company.com"
  }'
```

## Troubleshooting

### Script Fails with "Node.js not found"

**Solution**: Install Node.js from https://nodejs.org

### Script Fails with "npm not found"

**Solution**: npm comes with Node.js. Reinstall Node.js or ensure it's in your PATH.

### Docker Container Won't Start

**Solution**: 
- Check Docker Desktop is running
- Verify port 5678 is not in use
- Check Docker logs: `docker logs n8n`

### Webhook Configuration Fails

**Solution**:
- Verify your Git platform token has the correct permissions
- Check the token hasn't expired
- Manually configure webhooks (see Step 5 above)

### n8n Not Accessible

**Solution**:
- Check n8n is running: `docker ps` or check n8n process
- Verify port 5678 is accessible: `curl http://localhost:5678`
- For remote access, use ngrok or configure firewall rules

### Workflow Import Fails

**Solution**:
- Verify n8n is running and accessible
- Check workflow JSON files are valid: `node -e "JSON.parse(require('fs').readFileSync('workflows/feature-automation.json', 'utf8'))"`
- Import workflows one at a time in n8n UI

## Manual Setup Alternative

If you prefer to set up manually or the scripts don't work for your environment:

1. **Follow QUICKSTART.md** for step-by-step manual instructions
2. **Read docs/setup-guide.md** for detailed configuration
3. **Use scripts/setup-webhook.js** manually for webhook setup

## Next Steps After Setup

1. ✅ Import workflows in n8n UI
2. ✅ Configure credentials in n8n (GitHub, Slack, etc.)
3. ✅ Test the integration using the test commands
4. ✅ Review workflow examples in `docs/workflow-examples.md`
5. ✅ Customize workflows for your specific needs

## Security Notes

- 🔒 Never commit `.env` file to Git (already in `.gitignore`)
- 🔒 Keep your Git platform tokens secure
- 🔒 Use webhook secrets for secure webhook validation
- 🔒 Regularly rotate access tokens
- 🔒 Limit token permissions to minimum required

## Support

For issues or questions:
- Check `QUICKSTART.md` for quick setup guide
- Review `docs/setup-guide.md` for detailed instructions
- Check workflow JSON files for configuration details
- Test individual workflows in n8n test mode

---

**Happy Automating! 🚀**

