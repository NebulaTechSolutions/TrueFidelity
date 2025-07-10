# Git Hooks

This directory contains git hooks to prevent AI assistant references in the codebase.

## Installation

### Automatic Installation
Run the install script:
```bash
./.githooks/install.sh
```

### Manual Installation
Copy hooks to your local git directory:
```bash
cp .githooks/pre-commit .git/hooks/
cp .githooks/commit-msg .git/hooks/
chmod +x .git/hooks/*
```

### Using Shared Hooks Directory
Configure git to use this directory for all hooks:
```bash
git config core.hooksPath .githooks
```

## What These Hooks Do

### pre-commit
- Scans staged files for AI assistant references
- Blocks commits containing terms like "Claude", "anthropic.com", etc.
- Excludes the .githooks directory itself from checks

### commit-msg
- Checks commit messages for AI assistant references
- Prevents commits with AI-generated signatures or mentions

## Bypassing Hooks (Emergency Only)
If you absolutely need to bypass these checks:
```bash
git commit --no-verify -m "your message"
```

**Note:** This should only be used in exceptional circumstances.