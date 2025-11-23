# Quick Start Guide

Get up and running with n8n SDLC integration in 5 minutes!

## 🚀 Prerequisites

- n8n instance (self-hosted or cloud)
- Git repository (GitHub/GitLab)
- Terminal access

## ⚡ Quick Setup

### 1. Install n8n (if not already installed)

**Using Docker:**
```bash
docker run -it --rm \
  --name n8n \
  -p 5678:5678 \
  n8nio/n8n
```

**Using npm:**
```bash
npm install n8n -g
n8n start
```

Access n8n at: `http://localhost:5678`

### 2. Import Workflows

1. Open n8n UI: `http://localhost:5678`
2. Click **"Workflows"** → **"Import from File"**
3. Select these files from `workflows/` directory:
   - `feature-automation.json` - For automating feature development
   - `ci-cd-integration.json` - For CI/CD automation
   - `notifications.json` - For team notifications
   - `code-quality.json` - For code quality checks

### 3. Configure Credentials

**GitHub:**
1. Settings → Credentials → Add Credential
2. Select "GitHub API"
3. Create Personal Access Token at: https://github.com/settings/tokens
4. Token scopes: `repo`, `workflow`

**Slack (Optional):**
1. Create Slack App: https://api.slack.com/apps
2. Enable Incoming Webhooks
3. Copy webhook URL
4. Add to environment variables: `SLACK_WEBHOOK_URL`

### 4. Set Up Webhook

**Using the script:**
```bash
export N8N_WEBHOOK_URL="https://your-n8n-instance.com/webhook"
export GIT_PLATFORM_TOKEN="your-github-token"
export REPO_OWNER="your-org"
export REPO_NAME="your-repo"

node scripts/setup-webhook.js create
```

**Or manually:**
1. Go to GitHub repository → Settings → Webhooks
2. Add webhook:
   - Payload URL: `https://your-n8n-instance.com/webhook/git-webhook`
   - Content type: `application/json`
   - Events: Push, Pull request

### 5. Test the Integration

**Test Feature Creation:**
```bash
curl -X POST https://your-n8n-instance.com/webhook/feature-request \
  -H "Content-Type: application/json" \
  -d '{
    "action": "create_feature",
    "repository": "your-org/your-repo",
    "feature_name": "test-feature",
    "ticket_id": "TEST-123",
    "feature_type": "api",
    "description": "Test feature",
    "developer": "developer@company.com"
  }'
```

**Expected Result:**
- ✅ Feature branch created: `feature/TEST-123-test-feature`
- ✅ Boilerplate code generated
- ✅ Pull request created
- ✅ Notification sent (if Slack configured)

## 📋 Common Use Cases

### Use Case 1: Developer Starts a Feature

1. Developer sends POST request to `/webhook/feature-request`
2. Workflow creates branch and generates boilerplate
3. Developer gets PR link and can start coding

**Example Request:**
```json
{
  "action": "create_feature",
  "repository": "mycompany/api",
  "feature_name": "user-authentication",
  "ticket_id": "PROJ-123",
  "feature_type": "api",
  "description": "Implement JWT authentication"
}
```

### Use Case 2: Automated Testing

1. Developer pushes code to feature branch
2. Git webhook triggers n8n workflow
3. Workflow runs tests automatically
4. Results posted to PR as comment

**No action needed** - Works automatically when webhook is configured!

### Use Case 3: Team Notifications

1. PR created → Team notified via Slack
2. Tests complete → Status update sent
3. Deployment ready → QA team notified

**Configure once, works forever!**

## 🎯 Next Steps

1. **Customize Workflows**: Adjust workflows for your specific needs
2. **Add More Integrations**: Connect JIRA, Teams, Discord, etc.
3. **Set Up More Webhooks**: Configure for multiple repositories
4. **Monitor Executions**: Check n8n execution history regularly

## 🔧 Troubleshooting

### Webhook not working?
- ✅ Check webhook URL is publicly accessible
- ✅ Verify webhook events are enabled
- ✅ Check n8n execution logs

### Credentials failing?
- ✅ Verify token has correct scopes
- ✅ Check token hasn't expired
- ✅ Ensure credentials are saved in n8n

### Workflow not executing?
- ✅ Check workflow is activated
- ✅ Verify webhook path matches
- ✅ Review execution history for errors

## 📚 Documentation

- **Full Setup Guide**: See `docs/setup-guide.md`
- **Workflow Examples**: See `docs/workflow-examples.md`
- **README**: See `README.md`

## 💡 Tips

1. **Test First**: Use test mode in n8n to debug workflows
2. **Start Small**: Begin with one workflow, then expand
3. **Monitor Logs**: Check execution history regularly
4. **Iterate**: Improve workflows based on team feedback

## 🆘 Need Help?

- Check documentation in `docs/` directory
- Review workflow JSON files for configuration
- Test individual nodes in n8n test mode
- Check n8n community: https://community.n8n.io

---

**Happy Automating! 🚀**

