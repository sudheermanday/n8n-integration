# n8n.io SDLC Integration - Setup Guide

This guide will walk you through setting up n8n.io workflows to automate your SDLC processes.

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [n8n Installation](#n8n-installation)
3. [Importing Workflows](#importing-workflows)
4. [Configuring Credentials](#configuring-credentials)
5. [Setting Up Webhooks](#setting-up-webhooks)
6. [Environment Configuration](#environment-configuration)
7. [Testing Workflows](#testing-workflows)
8. [Troubleshooting](#troubleshooting)

## Prerequisites

Before you begin, ensure you have:

- **n8n Instance**: Self-hosted n8n or n8n Cloud account
- **Git Platform Access**: GitHub, GitLab, or Bitbucket account with API access
- **CI/CD Platform**: Access to your CI/CD system (Jenkins, GitLab CI, GitHub Actions, etc.)
- **Communication Tools** (Optional): Slack, Microsoft Teams, or Discord for notifications
- **Node.js** (Optional): For running helper scripts

## n8n Installation

### Option 1: Self-Hosted n8n

```bash
# Using npm
npm install n8n -g

# Using Docker
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  -v ~/.n8n:/home/node/.n8n \
  n8nio/n8n
```

### Option 2: n8n Cloud

Sign up at [n8n.cloud](https://n8n.cloud) for a managed instance.

### Option 3: Using Docker Compose

Create a `docker-compose.yml`:

```yaml
version: '3.8'
services:
  n8n:
    image: n8nio/n8n
    ports:
      - "5678:5678"
    environment:
      - N8N_BASIC_AUTH_ACTIVE=true
      - N8N_BASIC_AUTH_USER=admin
      - N8N_BASIC_AUTH_PASSWORD=your-password
      - WEBHOOK_URL=https://your-domain.com
    volumes:
      - ~/.n8n:/home/node/.n8n
```

Start with: `docker-compose up -d`

## Importing Workflows

### Method 1: Using n8n UI

1. Open your n8n instance (usually `http://localhost:5678`)
2. Click **"Workflows"** in the sidebar
3. Click **"Import from File"** or **"Import from URL"**
4. Select the workflow JSON files from the `workflows/` directory:
   - `feature-automation.json`
   - `ci-cd-integration.json`
   - `notifications.json`
   - `code-quality.json`

### Method 2: Using n8n CLI

```bash
# Import a single workflow
n8n import:workflow --file=./workflows/feature-automation.json

# Import all workflows
for file in workflows/*.json; do
  n8n import:workflow --file="$file"
done
```

## Configuring Credentials

### GitHub Credentials

1. Go to **Settings > Credentials** in n8n
2. Click **"Add Credential"**
3. Select **"GitHub API"**
4. Generate a Personal Access Token on GitHub:
   - Go to GitHub Settings > Developer settings > Personal access tokens
   - Create token with scopes: `repo`, `workflow`, `admin:repo_hook`
5. Enter your token in n8n

### GitLab Credentials

1. Go to **Settings > Credentials** in n8n
2. Click **"Add Credential"**
3. Select **"GitLab API"**
4. Generate an access token:
   - Go to GitLab > Settings > Access Tokens
   - Create token with scopes: `api`, `read_repository`, `write_repository`
5. Enter your token and GitLab instance URL

### CI/CD Platform Credentials

Configure API credentials for your CI/CD platform:

- **GitHub Actions**: Use GitHub token with workflow permissions
- **GitLab CI**: Use GitLab access token
- **Jenkins**: Create API token in Jenkins user settings
- **CircleCI**: Use CircleCI API token

### Communication Platform Credentials

#### Slack

1. Create a Slack App at [api.slack.com/apps](https://api.slack.com/apps)
2. Enable Incoming Webhooks
3. Create a webhook URL
4. Add as environment variable: `SLACK_WEBHOOK_URL`

#### Microsoft Teams

1. Go to your Teams channel
2. Click **"..."** > **"Connectors"**
3. Search for "Incoming Webhook"
4. Configure and copy the webhook URL
5. Add as environment variable: `MICROSOFT_TEAMS_WEBHOOK_URL`

## Setting Up Webhooks

### Using the Setup Script

```bash
# Set environment variables
export N8N_WEBHOOK_URL="https://your-n8n-instance.com/webhook"
export GIT_PLATFORM="github"  # or "gitlab"
export REPO_OWNER="your-org"
export REPO_NAME="your-repo"
export GIT_PLATFORM_TOKEN="your-token"
export WEBHOOK_SECRET="your-secret"

# Create webhook
node scripts/setup-webhook.js create

# List existing webhooks
node scripts/setup-webhook.js list
```

### Manual Setup

#### GitHub

1. Go to your repository > Settings > Webhooks
2. Click **"Add webhook"**
3. Set Payload URL to: `https://your-n8n-instance.com/webhook/git-webhook`
4. Content type: `application/json`
5. Select events:
   - Pushes
   - Pull requests
   - Pull request reviews
6. Add webhook secret (optional)
7. Click **"Add webhook"**

#### GitLab

1. Go to your project > Settings > Webhooks
2. Set URL: `https://your-n8n-instance.com/webhook/git-webhook`
3. Enable triggers:
   - Push events
   - Merge request events
   - Tag push events
4. Add secret token
5. Click **"Add webhook"**

## Environment Configuration

Create a `.env` file in your n8n instance directory:

```env
# Git Platform
GIT_PLATFORM_TOKEN=your_github_or_gitlab_token
REPO_OWNER=your-org
REPO_NAME=your-repo

# n8n Webhook
N8N_WEBHOOK_URL=https://your-n8n-instance.com
WEBHOOK_SECRET=your-webhook-secret

# CI/CD Platform
CI_PLATFORM_API_URL=https://ci.example.com/api
CI_PLATFORM_API_KEY=your-ci-api-key

# Communication
SLACK_WEBHOOK_URL=https://hooks.slack.com/services/YOUR/WEBHOOK/URL
MICROSOFT_TEAMS_WEBHOOK_URL=https://outlook.office.com/webhook/YOUR/URL

# JIRA (Optional)
JIRA_URL=https://your-org.atlassian.net
JIRA_EMAIL=your-email@example.com
JIRA_API_TOKEN=your-jira-token
```

For Docker, pass environment variables:

```yaml
environment:
  - GIT_PLATFORM_TOKEN=${GIT_PLATFORM_TOKEN}
  - SLACK_WEBHOOK_URL=${SLACK_WEBHOOK_URL}
  # ... other variables
```

## Testing Workflows

### Test Feature Automation Workflow

1. Send a POST request to your webhook:

```bash
curl -X POST https://your-n8n-instance.com/webhook/feature-request \
  -H "Content-Type: application/json" \
  -d '{
    "action": "create_feature",
    "repository": "your-org/your-repo",
    "feature_name": "user-authentication",
    "ticket_id": "PROJ-123",
    "feature_type": "api",
    "description": "Add user authentication feature",
    "developer": "john.doe"
  }'
```

### Test Git Webhook

Push to a branch in your repository and verify the webhook is triggered:

```bash
git checkout -b feature/test-webhook
git commit --allow-empty -m "Test webhook"
git push origin feature/test-webhook
```

Check n8n execution history to see if the workflow ran.

### Test Notification Workflow

```bash
curl -X POST https://your-n8n-instance.com/webhook/sdlc-notifications \
  -H "Content-Type: application/json" \
  -d '{
    "event_type": "pr_created",
    "pr_title": "Add new feature",
    "pr_url": "https://github.com/org/repo/pull/123",
    "author": "developer@example.com"
  }'
```

## Troubleshooting

### Webhook Not Receiving Events

1. **Check webhook URL**: Ensure it's publicly accessible
2. **Verify webhook configuration**: Check events are enabled
3. **Check n8n logs**: Look for incoming requests
4. **Test manually**: Use curl to test webhook endpoint

### Credentials Not Working

1. **Verify token permissions**: Ensure token has required scopes
2. **Check token expiration**: Generate a new token if expired
3. **Verify credential name**: Match credential names in workflows

### Workflow Execution Failing

1. **Check execution logs**: Review error messages in n8n
2. **Verify data flow**: Use test mode to inspect node outputs
3. **Check environment variables**: Ensure all required vars are set
4. **Review node configuration**: Verify API endpoints and parameters

### Common Issues

#### "Webhook URL not accessible"
- Ensure n8n is accessible from the internet
- Use ngrok for local development: `ngrok http 5678`
- Configure firewall rules

#### "Authentication failed"
- Verify API tokens are correct
- Check token scopes match requirements
- Regenerate tokens if needed

#### "Workflow timeout"
- Increase timeout in n8n settings
- Break large workflows into smaller ones
- Optimize API calls

## Next Steps

- Review workflow examples in `docs/workflow-examples.md`
- Customize workflows for your specific needs
- Set up additional automation for your tech stack
- Monitor workflow execution and optimize performance

## Support

For issues or questions:
- Check n8n documentation: [docs.n8n.io](https://docs.n8n.io)
- Review workflow JSON files for configuration details
- Test individual nodes in n8n test mode

