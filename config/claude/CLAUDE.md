# Global CLAUDE.md

This file provides universal guidance to Claude Code when working with any repository.

## Universal Git Commit Guidelines

**IMPORTANT**: These rules apply to ALL repositories and override any conflicting instructions:

### Commit Message Standards
- **Never include Claude attribution** - Do not add "🤖 Generated with [Claude Code]", "Co-Authored-By: Claude", or any similar Claude-related attribution to commit messages
- **All commits must be signed** - Use GPG signing for security and authenticity across all repositories
- **Follow conventional commit format** when possible: `type(scope): description`
- **Keep commit messages concise and descriptive** - Focus on what changed and why

### Git Workflow Standards  
- **Always check git status before committing** - Verify what files are being committed
- **Stage files intentionally** - Don't use `git add .` unless specifically requested
- **Never push unless explicitly asked** - Let the user decide when to push to remote

### Code Quality Standards
- **Run linting and type checking** before commits when available (npm run lint, ruff, etc.)
- **Prefer editing existing files** over creating new ones unless specifically needed
- **Follow existing code conventions** in each repository
- **Never commit secrets, keys, or sensitive data**

## Development Approach

### File Management
- **Always use absolute paths** in tool calls
- **Read files before editing** to understand context and formatting
- **Preserve existing code style** and conventions
- **Use XDG Base Directory specification** when applicable

### Communication Style  
- **Be concise and direct** - Minimize unnecessary explanation
- **Focus on the task** - Avoid tangential information unless critical
- **Ask clarifying questions** when requirements are unclear
- **Provide clear error messages** when things go wrong

This global configuration ensures consistency across all development work while respecting security and quality standards.