#!/bin/bash
# Install git hooks for the project

HOOKS_DIR=".githooks"
GIT_HOOKS_DIR=".git/hooks"

echo "Installing git hooks..."

# Create hooks directory if it doesn't exist
mkdir -p "$GIT_HOOKS_DIR"

# Install each hook
for hook in pre-commit commit-msg; do
    if [ -f "$HOOKS_DIR/$hook" ]; then
        echo "Installing $hook hook..."
        cp "$HOOKS_DIR/$hook" "$GIT_HOOKS_DIR/$hook"
        chmod +x "$GIT_HOOKS_DIR/$hook"
    fi
done

# Configure git to use the shared hooks directory (alternative method)
git config core.hooksPath "$HOOKS_DIR"

echo "Git hooks installed successfully!"
echo "The following protections are now active:"
echo "  - Pre-commit: Blocks files containing AI assistant references"
echo "  - Commit-msg: Blocks commit messages with AI assistant references"