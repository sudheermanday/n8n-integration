# Workflow Examples & Use Cases

This document provides detailed examples of how to use the n8n SDLC workflows in various scenarios.

## Table of Contents

1. [Feature Development Automation](#feature-development-automation)
2. [CI/CD Integration](#cicd-integration)
3. [Code Quality Automation](#code-quality-automation)
4. [Notification & Collaboration](#notification--collaboration)
5. [Custom Workflow Examples](#custom-workflow-examples)

## Feature Development Automation

### Scenario: Starting a New API Feature

**Trigger**: Developer wants to start a new feature for user authentication API.

**Request**:
```json
POST /webhook/feature-request
{
  "action": "create_feature",
  "repository": "mycompany/backend-api",
  "feature_name": "user-authentication",
  "ticket_id": "PROJ-123",
  "feature_type": "api",
  "description": "Implement JWT-based user authentication",
  "developer": "john.doe@company.com"
}
```

**What Happens**:
1. ✅ Creates branch: `feature/PROJ-123-user-authentication`
2. ✅ Generates boilerplate files:
   - `src/routes/user-authentication.js`
   - `src/controllers/user-authenticationController.js`
   - `src/services/user-authenticationService.js`
   - `tests/user-authentication.test.js`
3. ✅ Commits files with initial commit
4. ✅ Opens Pull Request with template
5. ✅ Notifies team via Slack

**Response**:
```json
{
  "success": true,
  "message": "Feature branch created successfully",
  "branch": "feature/PROJ-123-user-authentication",
  "pr_url": "https://github.com/mycompany/backend-api/pull/456"
}
```

### Scenario: Starting a New UI Component

**Request**:
```json
POST /webhook/feature-request
{
  "action": "create_feature",
  "repository": "mycompany/frontend",
  "feature_name": "login-form",
  "ticket_id": "PROJ-124",
  "feature_type": "ui",
  "description": "Create login form component with validation",
  "developer": "jane.smith@company.com"
}
```

**Generated Files**:
- `src/components/LoginForm/LoginForm.jsx`
- `src/components/LoginForm/LoginForm.css`
- `src/components/LoginForm/index.js`
- `src/components/LoginForm/LoginForm.test.jsx`

## CI/CD Integration

### Scenario: Automatic Testing on Push

**Trigger**: Developer pushes code to a feature branch.

**Workflow**:
1. Git webhook receives push event
2. Extracts branch name and commit SHA
3. Triggers automated test suite
4. Runs code quality checks (ESLint, SonarQube)
5. Updates PR status with results
6. Sends notification if tests fail

**Webhook Payload** (from Git):
```json
{
  "ref": "refs/heads/feature/PROJ-123-user-auth",
  "after": "abc123def456",
  "repository": {
    "full_name": "mycompany/backend-api"
  },
  "pusher": {
    "name": "john.doe"
  }
}
```

### Scenario: Automatic Deployment to Staging

**Trigger**: Code is pushed to `main` branch.

**Workflow**:
1. Detects push to `main` branch
2. Triggers build process
3. Runs full test suite
4. If successful, builds Docker image
5. Deploys to staging environment
6. Runs smoke tests
7. Notifies QA team

**Customization**:
- Add approval step for production deployments
- Implement blue-green deployment
- Add rollback automation

## Code Quality Automation

### Scenario: Automated Code Review

**Trigger**: Pull request is opened or updated.

**Workflow**:
1. Fetches changed files from PR
2. Runs ESLint on JavaScript files
3. Checks code complexity
4. Analyzes code coverage
5. Posts results as PR comment
6. Blocks merge if critical issues found

**Example PR Comment**:
```markdown
## Code Quality Report

❌ **Errors Found**

### Issues:
- **Line 45**: Use let or const instead of var (no-var)
- **Line 78**: console.log should be removed before production (no-console)

### Suggestions:
- Cyclomatic complexity is high. Consider breaking down this function.
- File is quite large. Consider splitting into smaller modules.
```

### Scenario: Automated Security Scanning

**Extension**: Add security scanning to code quality workflow.

**Additional Steps**:
1. Run Snyk security scan
2. Check for vulnerable dependencies
3. Scan for secrets in code
4. Review OWASP Top 10 compliance
5. Generate security report

## Notification & Collaboration

### Scenario: PR Created Notification

**Request**:
```json
POST /webhook/sdlc-notifications
{
  "event_type": "pr_created",
  "pr_title": "Add user authentication",
  "pr_url": "https://github.com/org/repo/pull/123",
  "pr_description": "Implements JWT-based authentication",
  "author": "john.doe@company.com",
  "branch": "feature/PROJ-123-user-auth"
}
```

**Notification Sent to Slack**:
```
🔵 New Pull Request

PR: Add user authentication
📝 Implements JWT-based authentication
👤 Author: john.doe@company.com
🔗 View PR: https://github.com/org/repo/pull/123
```

### Scenario: Deployment Notification

**Request**:
```json
POST /webhook/sdlc-notifications
{
  "event_type": "deployment",
  "environment": "production",
  "status": "success",
  "version": "v1.2.3",
  "deployed_by": "ci-bot",
  "commit": "abc123"
}
```

**Notification Sent**:
```
🚀 Deployment Status

Environment: production
📍 Status: success
📦 Version: v1.2.3
👤 Deployed by: ci-bot
```

## Custom Workflow Examples

### Example 1: Automated Dependency Updates

**Use Case**: Automatically create PRs for dependency updates.

**Workflow**:
1. Scheduled trigger (daily/weekly)
2. Check for outdated dependencies
3. Create branch for updates
4. Update package files
5. Run tests
6. Create PR with changelog

### Example 2: Release Automation

**Use Case**: Automate release process.

**Workflow**:
1. Trigger on version tag creation
2. Generate release notes from commits
3. Create GitHub release
4. Build and publish packages
5. Update changelog
6. Notify stakeholders

### Example 3: Environment Sync

**Use Case**: Keep environments in sync.

**Workflow**:
1. Monitor configuration changes
2. Validate configuration files
3. Deploy to staging automatically
4. Wait for approval for production
5. Deploy to production with approval

### Example 4: Automated Documentation

**Use Case**: Generate docs from code changes.

**Workflow**:
1. Trigger on PR merge
2. Extract API endpoints from code
3. Generate OpenAPI/Swagger spec
4. Update documentation site
5. Notify documentation team

### Example 5: Developer Onboarding

**Use Case**: Help new developers get started.

**Workflow**:
1. Trigger on new team member
2. Create developer setup checklist
3. Generate initial PR with setup scripts
4. Assign mentor
5. Schedule onboarding tasks

## Integration Patterns

### Pattern 1: Event-Driven Architecture

```
Git Event → Webhook → n8n → Multiple Actions
  ├─ CI/CD Platform
  ├─ Communication Tools
  ├─ Issue Trackers
  └─ Documentation Systems
```

### Pattern 2: Approval Gates

```
Code Push → Tests → Quality Checks → Approval Gate → Deployment
                                  ↓
                            Wait for Approval
                                  ↓
                            Deploy to Production
```

### Pattern 3: Fan-Out Pattern

```
Feature Request → Multiple Parallel Actions
  ├─ Create Branch
  ├─ Generate Code
  ├─ Create PR
  ├─ Notify Team
  └─ Create Tasks
```

## Best Practices

1. **Idempotency**: Make workflows idempotent (safe to rerun)
2. **Error Handling**: Always handle errors gracefully
3. **Notifications**: Notify on both success and failure
4. **Logging**: Log all important actions
5. **Testing**: Test workflows in staging first
6. **Documentation**: Document custom workflows
7. **Security**: Never expose secrets in logs
8. **Performance**: Optimize workflow execution time

## Tips & Tricks

### Using Environment Variables

Access environment variables in n8n:
```
={{ $env.SLACK_WEBHOOK_URL }}
```

### Conditional Logic

Use IF nodes for conditional flows:
- Check branch name
- Verify PR status
- Validate input data

### Error Handling

Use Error Trigger nodes:
```javascript
{
  "continueOnFail": true,
  "retry": {
    "maxTries": 3
  }
}
```

### Data Transformation

Use Code nodes for complex transformations:
```javascript
// Transform Git webhook payload
const branch = $input.item.json.ref.split('/').pop();
const repo = $input.item.json.repository.full_name;
return [{ json: { branch, repo } }];
```

## Getting Help

- Check n8n documentation: [docs.n8n.io](https://docs.n8n.io)
- Review workflow JSON files for node configurations
- Use n8n test mode to debug workflows
- Check execution history for error details

