# Git Setup and Push Guide

This guide helps you initialize git repository and push your n8n SDLC integration code to a remote repository (GitHub, GitLab, Bitbucket, etc.).

## Quick Setup

### Windows PowerShell (Recommended)

**Initialize and push in one command:**
```powershell
.\git-setup.ps1 -REMOTE_URL "https://github.com/your-username/your-repo.git" -Initialize
```

**Just push to existing repository:**
```powershell
.\git-setup.ps1 -REMOTE_URL "https://github.com/your-username/your-repo.git" -BRANCH "main"
```

### Linux/Mac

**Make script executable:**
```bash
chmod +x git-setup.sh
```

**Initialize and push in one command:**
```bash
./git-setup.sh --remote-url "https://github.com/your-username/your-repo.git" --initialize
```

**Just push to existing repository:**
```bash
./git-setup.sh --remote-url "https://github.com/your-username/your-repo.git" --branch "main"
```

## Manual Setup

If you prefer to set up git manually:

### Step 1: Initialize Git Repository

```bash
git init
```

### Step 2: Add All Files

```bash
git add .
```

### Step 3: Create Initial Commit

```bash
git commit -m "Initial commit: n8n SDLC integration setup"
```

### Step 4: Add Remote Repository

**For GitHub:**
```bash
git remote add origin https://github.com/your-username/your-repo.git
```

**For GitLab:**
```bash
git remote add origin https://gitlab.com/your-username/your-repo.git
```

**For Bitbucket:**
```bash
git remote add origin https://bitbucket.org/your-username/your-repo.git
```

### Step 5: Create Branch and Push

```bash
git checkout -b main
git push -u origin main
```

## Creating a Repository

### GitHub

1. Go to [GitHub](https://github.com) and sign in
2. Click the **"+"** icon → **"New repository"**
3. Enter repository name (e.g., `n8n-sdlc-integration`)
4. Choose visibility (Public/Private)
5. **Don't** initialize with README, .gitignore, or license (we already have these)
6. Click **"Create repository"**
7. Copy the repository URL (e.g., `https://github.com/your-username/n8n-sdlc-integration.git`)

### GitLab

1. Go to [GitLab](https://gitlab.com) and sign in
2. Click **"New project"** → **"Create blank project"**
3. Enter project name (e.g., `n8n-sdlc-integration`)
4. Choose visibility level
5. **Don't** initialize with README
6. Click **"Create project"**
7. Copy the repository URL

### Bitbucket

1. Go to [Bitbucket](https://bitbucket.org) and sign in
2. Click **"Create"** → **"Repository"**
3. Enter repository name (e.g., `n8n-sdlc-integration`)
4. Choose visibility
5. **Don't** initialize with README or .gitignore
6. Click **"Create repository"**
7. Copy the repository URL

## Authentication

### Personal Access Token (Recommended)

**GitHub:**
1. Go to Settings → Developer settings → Personal access tokens → Tokens (classic)
2. Click "Generate new token"
3. Select scopes: `repo` (full control of private repositories)
4. Copy the token
5. Use it as password when pushing (username = your GitHub username)

**GitLab:**
1. Go to Settings → Access Tokens
2. Create token with `write_repository` scope
3. Copy the token
4. Use it as password when pushing

### SSH Keys (Alternative)

**Generate SSH key:**
```bash
ssh-keygen -t ed25519 -C "your_email@example.com"
```

**Add to GitHub:**
1. Copy public key: `cat ~/.ssh/id_ed25519.pub`
2. Go to GitHub → Settings → SSH and GPG keys
3. Click "New SSH key"
4. Paste your public key

**Use SSH URL:**
```bash
git remote set-url origin git@github.com:your-username/your-repo.git
```

## Using the Scripts

### What the Scripts Do

1. ✅ Check if git is installed
2. ✅ Initialize git repository (if needed)
3. ✅ Add all files to staging
4. ✅ Commit changes with appropriate message
5. ✅ Add remote repository
6. ✅ Create/switch to branch
7. ✅ Push to remote repository

### Script Options

**Windows PowerShell:**
```powershell
.\git-setup.ps1 -Help
```

**Linux/Mac:**
```bash
./git-setup.sh --help
```

### Interactive Mode

**Windows PowerShell:**
```powershell
# Will prompt for remote URL if not provided
.\git-setup.ps1 -Initialize
```

**Linux/Mac:**
```bash
# Will prompt for remote URL if not provided
./git-setup.sh --initialize
```

## Branch Management

### Default Branch

The scripts use `main` as the default branch. To use a different branch:

**PowerShell:**
```powershell
.\git-setup.ps1 -REMOTE_URL "..." -BRANCH "develop"
```

**Bash:**
```bash
./git-setup.sh --remote-url "..." --branch "develop"
```

### Common Branches

- `main` - Production branch (default)
- `develop` - Development branch
- `master` - Legacy default branch name

## Troubleshooting

### "Git not found" Error

**Solution**: Install Git from https://git-scm.com

**Windows**: Download and run the installer
**Linux**: `sudo apt-get install git` (Ubuntu/Debian) or `sudo yum install git` (CentOS/RHEL)
**Mac**: `brew install git` or download from git-scm.com

### "Authentication failed" Error

**Solution**: 
- Use Personal Access Token instead of password
- Verify your token has correct permissions
- Check remote URL is correct

### "Remote already exists" Warning

**Solution**: 
- Script will ask if you want to update remote URL
- Or manually update: `git remote set-url origin <new-url>`
- Or remove and re-add: `git remote remove origin && git remote add origin <url>`

### "Push failed" Error

**Solution**:
- Verify you have push permissions
- Check if branch exists on remote
- Try: `git push -u origin main --force` (use with caution)

### "Branch already exists" Error

**Solution**:
- Script will switch to existing branch automatically
- Or create different branch: `-BRANCH "feature/new-branch"`

## File Exclusions

The `.gitignore` file ensures sensitive files are not committed:
- `.env` - Environment variables (contains secrets)
- `node_modules/` - Dependencies
- `.n8n/` - n8n data files
- `*.log` - Log files
- `*.pem`, `*.key` - Secret keys

**Important**: Never commit `.env` file or any secrets!

## After Pushing

### Verify Push

```bash
git remote -v
git log --oneline
git branch -a
```

### Continue Development

```bash
# Make changes
git add .
git commit -m "Your commit message"
git push
```

### Clone Repository (for others)

```bash
git clone https://github.com/your-username/your-repo.git
cd your-repo
```

## Best Practices

1. ✅ **Never commit secrets**: `.env` file is in `.gitignore`
2. ✅ **Use meaningful commit messages**: Describe what changed
3. ✅ **Push regularly**: Keep remote repository updated
4. ✅ **Use branches**: Create feature branches for new work
5. ✅ **Review before push**: Check what you're committing

## Next Steps

After pushing your code:

1. ✅ Verify code is on remote repository
2. ✅ Set up repository settings (topics, description, etc.)
3. ✅ Configure branch protection rules (optional)
4. ✅ Add collaborators (if needed)
5. ✅ Set up CI/CD workflows (GitHub Actions, GitLab CI, etc.)

## Support

For issues or questions:
- Check Git documentation: https://git-scm.com/doc
- Review repository documentation in `README.md`
- Check `.gitignore` file to ensure sensitive files are excluded

---

**Happy Pushing! 🚀**

