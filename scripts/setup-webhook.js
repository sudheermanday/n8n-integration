/**
 * Script to set up webhooks in Git platforms (GitHub/GitLab)
 * This helps configure webhooks that trigger n8n workflows
 */

const https = require('https');

const WEBHOOK_URL = process.env.N8N_WEBHOOK_URL || 'http://your-n8n-instance.com/webhook';
const GIT_PLATFORM = process.env.GIT_PLATFORM || 'github'; // 'github' or 'gitlab'
const REPO_OWNER = process.env.REPO_OWNER || 'your-org';
const REPO_NAME = process.env.REPO_NAME || 'your-repo';
const ACCESS_TOKEN = process.env.GIT_PLATFORM_TOKEN;

if (!ACCESS_TOKEN) {
  console.error('Error: GIT_PLATFORM_TOKEN environment variable is required');
  process.exit(1);
}

// GitHub webhook configuration
const githubWebhookConfig = {
  name: 'web',
  active: true,
  events: [
    'push',
    'pull_request',
    'pull_request_review',
    'create',
    'delete'
  ],
  config: {
    url: WEBHOOK_URL,
    content_type: 'json',
    insecure_ssl: '0',
    secret: process.env.WEBHOOK_SECRET || 'your-webhook-secret'
  }
};

// GitLab webhook configuration
const gitlabWebhookConfig = {
  url: WEBHOOK_URL,
  push_events: true,
  merge_requests_events: true,
  tag_push_events: true,
  token: process.env.WEBHOOK_SECRET || 'your-webhook-secret',
  enable_ssl_verification: true
};

async function createWebhook() {
  const config = GIT_PLATFORM === 'github' ? githubWebhookConfig : gitlabWebhookConfig;
  const url = GIT_PLATFORM === 'github'
    ? `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/hooks`
    : `https://gitlab.com/api/v4/projects/${REPO_OWNER}%2F${REPO_NAME}/hooks`;

  return new Promise((resolve, reject) => {
    const postData = JSON.stringify(config);
    
    const options = {
      method: 'POST',
      headers: {
        'Content-Type': 'application/json',
        'Content-Length': Buffer.byteLength(postData),
        'Authorization': `Bearer ${ACCESS_TOKEN}`,
        'User-Agent': 'n8n-webhook-setup'
      }
    };

    const req = https.request(url, options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log('✅ Webhook created successfully!');
          console.log(JSON.parse(data));
          resolve(data);
        } else {
          console.error(`❌ Error creating webhook: ${res.statusCode}`);
          console.error(data);
          reject(new Error(`HTTP ${res.statusCode}`));
        }
      });
    });

    req.on('error', (e) => {
      console.error(`❌ Request error: ${e.message}`);
      reject(e);
    });

    req.write(postData);
    req.end();
  });
}

async function listWebhooks() {
  const url = GIT_PLATFORM === 'github'
    ? `https://api.github.com/repos/${REPO_OWNER}/${REPO_NAME}/hooks`
    : `https://gitlab.com/api/v4/projects/${REPO_OWNER}%2F${REPO_NAME}/hooks`;

  return new Promise((resolve, reject) => {
    const options = {
      method: 'GET',
      headers: {
        'Authorization': `Bearer ${ACCESS_TOKEN}`,
        'User-Agent': 'n8n-webhook-setup'
      }
    };

    const req = https.request(url, options, (res) => {
      let data = '';
      res.on('data', (chunk) => {
        data += chunk;
      });
      res.on('end', () => {
        if (res.statusCode >= 200 && res.statusCode < 300) {
          console.log('📋 Existing webhooks:');
          console.log(JSON.parse(data));
          resolve(data);
        } else {
          console.error(`❌ Error listing webhooks: ${res.statusCode}`);
          reject(new Error(`HTTP ${res.statusCode}`));
        }
      });
    });

    req.on('error', (e) => {
      console.error(`❌ Request error: ${e.message}`);
      reject(e);
    });

    req.end();
  });
}

// Main execution
const command = process.argv[2] || 'create';

if (command === 'create') {
  createWebhook().catch(console.error);
} else if (command === 'list') {
  listWebhooks().catch(console.error);
} else {
  console.log('Usage: node setup-webhook.js [create|list]');
  console.log('\nEnvironment variables:');
  console.log('  N8N_WEBHOOK_URL - Your n8n webhook URL');
  console.log('  GIT_PLATFORM - "github" or "gitlab"');
  console.log('  REPO_OWNER - Repository owner/organization');
  console.log('  REPO_NAME - Repository name');
  console.log('  GIT_PLATFORM_TOKEN - Access token');
  console.log('  WEBHOOK_SECRET - Webhook secret (optional)');
}

