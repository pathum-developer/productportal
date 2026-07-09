# GitHub Push Guide

Follow these steps to push your Product Portal repository to GitHub.

## 📋 Prerequisites

✅ Git installed and configured
✅ GitHub account created
✅ Local repository initialized with initial commit
✅ SSH key or Personal Access Token ready

---

## 🔧 Step-by-Step Instructions

### Option 1: Using SSH (Recommended for Enterprise)

#### 1. Generate SSH Key (if you don't have one)
```bash
ssh-keygen -t ed25519 -C "your.email@example.com"
# or for older systems:
ssh-keygen -t rsa -b 4096 -C "your.email@example.com"
```
- Press Enter to save to default location: `~/.ssh/id_ed25519`
- Set a passphrase (recommended for security)

#### 2. Add SSH Key to GitHub
```bash
# Copy public key to clipboard
# Windows PowerShell:
Get-Content $env:USERPROFILE\.ssh\id_ed25519.pub | Set-Clipboard

# Mac/Linux:
cat ~/.ssh/id_ed25519.pub | pbcopy
```

- Go to GitHub → Settings → SSH and GPG keys
- Click "New SSH key"
- Paste the key and save

#### 3. Test SSH Connection
```bash
ssh -T git@github.com
# Expected: Hi <username>! You've successfully authenticated...
```

#### 4. Create Repository on GitHub
- Go to [github.com](https://github.com)
- Click **+** (top-right) → **New repository**
- Repository name: `productportal`
- Description: `Professional Spring Boot e-commerce platform with enterprise patterns`
- Privacy: **Public** (or Private if preferred)
- **Do NOT** initialize with README/gitignore (you already have them)
- Click **Create repository**

#### 5. Add Remote and Push
```bash
cd "C:\Learn spring\productportal"

# Add remote repository
git remote add origin git@github.com:YOUR_USERNAME/productportal.git

# Verify remote
git remote -v
# Output:
# origin  git@github.com:YOUR_USERNAME/productportal.git (fetch)
# origin  git@github.com:YOUR_USERNAME/productportal.git (push)

# Rename branch to main (best practice)
git branch -M main

# Push to GitHub
git push -u origin main
```

---

### Option 2: Using HTTPS + Personal Access Token

#### 1. Create Personal Access Token on GitHub
- Go to GitHub → Settings → Developer settings → Personal access tokens
- Click **Generate new token (classic)**
- Set scopes: `repo` (full control of private repositories)
- Copy the token (save it somewhere secure)

#### 2. Add Remote and Push
```bash
cd "C:\Learn spring\productportal"

# Add remote with HTTPS
git remote add origin https://github.com/YOUR_USERNAME/productportal.git

# Push to GitHub (enter token as password)
git push -u origin main
```

---

## ✅ Verify Push

```bash
# Check remote status
git remote -v

# Verify on GitHub
# Go to https://github.com/YOUR_USERNAME/productportal
# You should see all your code and README.md
```

---

## 🎯 Next Steps

### 1. Add Branch Protection Rules (Optional)
- Go to repository → Settings → Branches
- Add rule for `main` branch:
  - Require pull request reviews before merging
  - Dismiss stale pull request approvals
  - Require branches to be up to date

### 2. Add GitHub Actions (CI/CD)
Create `.github/workflows/ci.yml`:
```yaml
name: Build & Test

on: [push, pull_request]

jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - name: Set up Java
        uses: actions/setup-java@v3
        with:
          java-version: '25'
          distribution: 'adopt'
      - name: Build with Maven
        run: mvn clean install
      - name: Run Tests
        run: mvn test
```

### 3. Add License
Create `LICENSE` file with MIT or Apache 2.0 license

### 4. Create CONTRIBUTING.md
Document contribution guidelines for collaborators

### 5. Setup Issues & Discussions
- Go to Settings → Features
- Enable Issues & Discussions for community engagement

---

## 🔗 Useful Commands

```bash
# Check status
git status

# View commit history
git log --oneline --graph --all

# View remote information
git remote -v
git remote show origin

# Update local after push
git fetch origin
git pull origin main

# Create new feature branch
git checkout -b feature/amazing-feature
git push -u origin feature/amazing-feature
```

---

## 🆘 Troubleshooting

### Error: "origin already exists"
```bash
git remote remove origin
git remote add origin git@github.com:YOUR_USERNAME/productportal.git
```

### Error: "Permission denied (publickey)"
- Verify SSH key is added to GitHub: `ssh -T git@github.com`
- Regenerate SSH key if needed

### Error: "Updates were rejected"
```bash
# Pull latest changes first
git pull origin main

# Resolve conflicts if any, then push
git push origin main
```

---

## 📚 Resources

- [GitHub SSH Setup](https://docs.github.com/en/authentication/connecting-to-github-with-ssh)
- [GitHub Personal Access Tokens](https://docs.github.com/en/authentication/keeping-your-account-and-data-secure/creating-a-personal-access-token)
- [Git Basics](https://git-scm.com/book/en/v2/Git-Basics-Getting-a-Git-Repository)
- [Conventional Commits](https://www.conventionalcommits.org/)

---

**Replace `YOUR_USERNAME` with your actual GitHub username before running commands!**
