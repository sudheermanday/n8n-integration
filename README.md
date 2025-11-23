# n8n.io SDLC Integration

This repository contains n8n.io workflow configurations to automate and fast-track your Software Development Life Cycle (SDLC) processes.

## 🚀 Overview

Integrate n8n.io into your SDLC to automate repetitive tasks and accelerate feature development. This integration provides workflows for:

- **Feature Development Automation**: Auto-generate feature branches, boilerplate code, and project scaffolding
- **CI/CD Integration**: Automated testing, building, and deployment workflows
- **Code Review & QA**: Automated PR checks, code quality scans, and test execution
- **Notifications & Collaboration**: Slack/Teams notifications for development events
- **Documentation Automation**: Auto-generate docs from code changes

## 📋 Features

### 1. Feature Branch Automation
- Automatically create feature branches with naming conventions
- Generate boilerplate code and file structure
- Set up required configuration files
- Trigger initial commits and PRs

### 2. Development Workflow Triggers
- Webhook-based triggers for Git events (push, PR, merge)
- Automated code quality checks
- Test execution on code changes
- Dependency update notifications

### 3. CI/CD Integration
- Automated build and test pipelines
- Deployment approval workflows
- Environment promotion automation
- Rollback procedures

### 4. Collaboration & Notifications
- Real-time notifications to Slack/Teams/Discord
- Automated status updates
- Code review reminders
- Deployment notifications

## 🛠️ Setup Instructions

### Docker Setup (Recommended)

**Quick start with Docker:**

**Windows PowerShell:**
```powershell
.\docker-setup.ps1 -Start
```

**Linux/Mac:**
```bash
chmod +x docker-setup.sh
./docker-setup.sh --start
```

**Or use Docker Compose directly:**
```bash
docker compose up -d
```

Access n8n at: `http://localhost:5678`
- Username: `admin`
- Password: `changeme` (change in `.env` file)

### Quick Setup (Automated)

**Use the setup script for automated installation:**

**Windows PowerShell:**
```powershell
.\setup.ps1
```

**Linux/Mac:**
```bash
chmod +x setup.sh
./setup.sh
```

**Windows CMD:**
```cmd
setup.bat
```

The setup scripts will:
- ✅ Check prerequisites (Node.js, npm, Docker)
- ✅ Install n8n (Docker or npm)
- ✅ Create `.env` file with configuration
- ✅ Configure webhooks automatically
- ✅ Provide test commands

See `SETUP_SCRIPTS.md` for detailed instructions on using the setup scripts.

### Push to Git Repository

**After setup, push your code to a remote repository:**

**Windows PowerShell:**
```powershell
.\git-setup.ps1 -REMOTE_URL "https://github.com/your-username/your-repo.git" -Initialize
```

**Linux/Mac:**
```bash
chmod +x git-setup.sh
./git-setup.sh --remote-url "https://github.com/your-username/your-repo.git" --initialize
```

See `GIT_SETUP.md` for detailed git setup instructions.

### Manual Setup

### Prerequisites
- n8n.io instance (self-hosted or cloud)
- Git repository access (GitHub/GitLab/Bitbucket)
- CI/CD platform (Jenkins, GitLab CI, GitHub Actions, etc.)
- Communication tools (Slack, Teams, etc.) - optional

### Installation

1. **Import Workflows**
   ```bash
   # Use n8n CLI or UI to import workflows
   npx n8n import:workflow --file=./workflows/feature-automation.json
   ```

2. **Configure Credentials**
   - Set up Git credentials in n8n
   - Configure CI/CD API tokens
   - Add communication tool webhooks

3. **Set Up Webhooks**
   - Configure webhook URLs in your Git platform
   - Add webhook secrets for security

4. **Environment Variables**
   ```bash
   # Example .env file
   GIT_PLATFORM_TOKEN=your_token_here
   SLACK_WEBHOOK_URL=your_webhook_url
   CI_PLATFORM_API_KEY=your_api_key
   ```

## 📁 Project Structure

```
.
├── workflows/              # n8n workflow JSON files
│   ├── feature-automation.json
│   ├── ci-cd-integration.json
│   ├── notifications.json
│   └── code-quality.json
├── scripts/               # Helper scripts
│   ├── setup-webhook.js
│   └── generate-boilerplate.js
├── templates/             # Code templates for automation
│   └── feature-template/
│       └── api-template.js
├── docs/                  # Documentation
│   ├── setup-guide.md
│   └── workflow-examples.md
├── docker-compose.yml     # Docker Compose configuration
├── Dockerfile             # Custom Docker image (optional)
├── docker-setup.ps1      # Docker management (PowerShell)
├── docker-setup.sh       # Docker management (Bash)
├── .dockerignore         # Docker ignore file
├── setup.ps1             # Windows PowerShell setup script
├── setup.sh              # Linux/Mac Bash setup script
├── setup.bat             # Windows CMD setup script
├── git-setup.ps1         # Git initialization and push (PowerShell)
├── git-setup.sh          # Git initialization and push (Bash)
├── SETUP_SCRIPTS.md       # Setup scripts documentation
├── GIT_SETUP.md           # Git setup and push guide
├── QUICKSTART.md          # Quick start guide
├── INTEGRATION_OVERVIEW.md # Integration overview
├── README.md              # This file
├── package.json           # Node.js project configuration
└── env.example            # Environment variables template
```

## 🎯 Quick Start

### Scenario 1: Starting a New Feature

1. Developer triggers workflow via webhook or Slack command
2. Workflow creates feature branch: `feature/JIRA-123-feature-name`
3. Generates boilerplate code based on feature type
4. Creates initial commit and opens PR with template
5. Notifies team via Slack/Teams

### Scenario 2: Code Push Automation

1. Developer pushes code to feature branch
2. Webhook triggers n8n workflow
3. Workflow runs automated tests
4. Performs code quality checks
5. Updates PR with status
6. Sends notification if issues found

### Scenario 3: PR Merge & Deployment

1. PR is merged to main branch
2. Workflow triggers automated build
3. Runs full test suite
4. If successful, deploys to staging
5. Notifies QA team
6. Creates deployment ticket

## 🔧 Workflow Configurations

### Feature Automation Workflow
**File**: `workflows/feature-automation.json`

This workflow automates the initial steps of feature development:
- Creates feature branch with proper naming
- Generates required files and folder structure
- Sets up basic configuration
- Opens initial PR

### CI/CD Integration Workflow
**File**: `workflows/ci-cd-integration.json`

Automates CI/CD processes:
- Triggers builds on code changes
- Runs tests and quality checks
- Handles deployment pipelines
- Manages environment promotions

### Notification Workflow
**File**: `workflows/notifications.json`

Sends notifications for various SDLC events:
- Branch creation
- PR status changes
- Test results
- Deployment status
- Code review reminders

## 📚 Documentation

See the `docs/` directory for detailed documentation:
- **setup-guide.md**: Complete setup instructions
- **workflow-examples.md**: Detailed workflow examples
- **api-reference.md**: API endpoints and webhooks

## 🔐 Security Best Practices

1. **Use Environment Variables**: Never hardcode credentials
2. **Webhook Secrets**: Always validate webhook signatures
3. **Token Management**: Use least-privilege access tokens
4. **Audit Logs**: Enable logging for all workflows
5. **Access Control**: Restrict workflow execution permissions

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Add your workflow improvements
4. Test thoroughly
5. Submit a PR

## 📝 License

MIT License - feel free to use and modify for your needs

## 🆘 Support

For issues or questions:
- Check the documentation in `docs/`
- Review workflow examples
- Open an issue in the repository

