# CLAUDE.md

AI assistant guide for working with the Cosmic67 repository.

## Repository Overview

**Repository**: cosmic67/cosmic67  
**Owner**: Cosmic67  
**Status**: New/early-stage project  
**Primary Branch**: main  
**Development Branches**: claude/* prefix for feature branches

This repository is currently in early stages with a minimal setup. The current structure includes only GitHub Actions workflow templates. Use this document as a reference for understanding the project structure, conventions, and workflows.

## Project Setup & Environment

### Prerequisites

- Git (v2.30+)
- Node.js/npm (if JavaScript project)
- Python 3.8+ (if Python project)
- Docker (optional, for containerized development)

### Repository Structure

```
Cosmic67/
├── .github/
│   └── workflows/
│       └── blank.yml              # GitHub Actions CI/CD template
├── .git/                          # Git repository metadata
├── CLAUDE.md                      # This file - AI assistant guide
└── (Project files will be added here)
```

### Initial Setup Commands

```bash
# Clone the repository
git clone https://github.com/Cosmic67/Cosmic67.git
cd Cosmic67

# Switch to development branch
git checkout claude/claude-md-docs-c8li8a

# Install dependencies (depends on project type)
npm install              # For Node.js projects
pip install -r requirements.txt  # For Python projects
```

## Development Workflow

### Branch Strategy

1. **main**: Production-ready code, always stable
2. **claude/*** : Feature branches for AI-assisted development
   - Format: `claude/<feature-description>-<ticket-id>`
   - Example: `claude/claude-md-docs-c8li8a`
   - Merge to main via pull request after review

### Commit Message Convention

Follow conventional commits format:

```
type(scope): description

[optional body with more details]
[optional footer with issue references]
```

**Types**:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `refactor`: Code refactoring without behavior change
- `perf`: Performance improvements
- `test`: Test additions/modifications
- `ci`: CI/CD changes
- `chore`: Build, dependencies, tooling

**Example**:
```
feat(core): add authentication module

Implements JWT-based authentication with:
- Token generation and validation
- Refresh token mechanism
- Rate limiting

Closes #42
```

### Pull Request Process

1. **Branch Creation**: Create feature branch from main
   ```bash
   git fetch origin main
   git checkout -b claude/feature-description-id origin/main
   ```

2. **Development**: Make changes following project conventions
   ```bash
   # Make changes
   git add <files>
   git commit -m "type(scope): description"
   ```

3. **Push to Remote**: Push branch with upstream tracking
   ```bash
   git push -u origin claude/feature-description-id
   ```

4. **Create PR**: Open pull request on GitHub
   - Title: Clear, concise description (under 70 chars)
   - Description: Detailed explanation of changes, test plan
   - Reference any related issues: "Closes #123"

5. **Review & Merge**: 
   - Address feedback and update commits
   - Maintain clean history (rebase if needed)
   - Squash commits when appropriate
   - Merge to main when approved

## Code Quality Standards

### Linting & Formatting

Maintain consistent code style:

- **JavaScript/TypeScript**: ESLint + Prettier
  ```bash
  npm run lint
  npm run format
  ```

- **Python**: Black, Flake8, isort
  ```bash
  black .
  flake8 .
  isort .
  ```

### Testing

All features must include tests:

```bash
npm test              # Node.js projects
pytest              # Python projects
```

Test coverage expectations:
- Minimum 80% for new features
- 100% for critical paths
- Branch coverage for conditionals

### Type Safety

- **TypeScript**: Enable strict mode
- **Python**: Use type hints and mypy for checking
  ```bash
  mypy .
  ```

## AI Assistant Conventions

### How Claude Should Approach Tasks

1. **Understand First**: Read relevant code and documentation before making changes
2. **Plan**: For complex tasks, outline the approach before implementation
3. **Minimal Changes**: Make focused changes that address the specific task
4. **Follow Style**: Match existing code patterns and conventions
5. **Test**: Verify changes work correctly before committing
6. **Document**: Update docs and comments when behavior changes

### File Operations

- **Prefer Edit over Write**: Use Edit tool for modifications to existing files
- **Preserve Structure**: Don't reorganize files unless explicitly requested
- **Avoid Deletions**: Remove code only if certain it's unused
- **Comment Sparingly**: Only add comments for non-obvious WHY, not WHAT

### Git Operations

- **Create Meaningful Commits**: Each commit should represent one logical change
- **Push Early**: Push to remote regularly to prevent loss of work
- **Review Before Push**: Check `git diff` and `git status` before committing
- **No Force Push**: Except when specifically authorized
- **Respect History**: Don't rewrite published history without permission

### When to Ask Questions

Always use `AskUserQuestion` or `Skill` tools when:
- Multiple valid approaches exist (ask which one to take)
- Trade-offs between options need user input
- Ambiguous requirements need clarification
- Risk assessment requires user judgment
- Architecture decisions affect multiple systems

## Documentation Standards

### README.md (to be created)

Should include:
- Project description and goals
- Quick start guide
- Installation instructions
- Usage examples
- Development setup
- Contributing guidelines
- License information

### Code Comments

- Explain **WHY**, not WHAT
- Keep comments close to the code they reference
- Update comments when code changes
- Remove outdated comments
- Use JSDoc/docstrings for public APIs

### Docstrings (Python)

```python
def function_name(param1: str, param2: int) -> bool:
    """Brief description.
    
    Longer description if needed.
    
    Args:
        param1: Description of param1
        param2: Description of param2
    
    Returns:
        Description of return value
    """
```

### JSDoc (JavaScript/TypeScript)

```javascript
/**
 * Brief description of function
 * @param {string} param1 - Description of param1
 * @param {number} param2 - Description of param2
 * @returns {boolean} Description of return value
 */
function functionName(param1, param2) {
  // implementation
}
```

## GitHub Actions & CI/CD

### Current Workflow

The `.github/workflows/blank.yml` file contains a basic CI template that:
- Triggers on push/PR to main branch
- Can be manually triggered via Actions tab
- Currently just echoes "Hello, world!"

### Workflow Customization

Update CI/CD workflow to include:

```yaml
# Add for Node.js projects
- name: Install dependencies
  run: npm install

- name: Run linter
  run: npm run lint

- name: Run tests
  run: npm run test

- name: Build
  run: npm run build
```

### Recommended Checks

Enable branch protection on main:
- Require status checks to pass
- Require pull request reviews
- Dismiss stale pull request approvals
- Require linear history

## Security Considerations

### Secrets Management

- Never commit secrets (.env files, credentials, API keys)
- Use GitHub Secrets for sensitive data
- Reference secrets in workflows: `${{ secrets.SECRET_NAME }}`
- Rotate secrets regularly

### Dependency Security

- Keep dependencies updated
- Monitor for security vulnerabilities
  ```bash
  npm audit
  npm audit fix
  ```
- Use dependabot for automated updates

### Code Review

- All changes should be reviewed before merge
- Security-sensitive code gets extra scrutiny
- Watch for injection vulnerabilities
- Validate user input at system boundaries

## Troubleshooting

### Common Issues

**Push fails with "rejected"**
- Check branch has no conflicts: `git pull origin <branch>`
- Ensure branch is up-to-date: `git fetch origin`
- Verify correct branch is selected: `git branch`

**Commit message is wrong**
- Amend last commit: `git commit --amend -m "new message"`
- Push with force-with-lease: `git push --force-with-lease`

**Changes lost after git operation**
- Check reflog: `git reflog`
- Recover commits: `git cherry-pick <commit-hash>`

**CI/CD workflow not running**
- Verify workflow file syntax (valid YAML)
- Check branch filter matches your branch
- Review workflow permissions in repository settings

## Resources & References

### Git Commands Reference

```bash
# View changes
git status          # See current changes
git diff            # See unstaged changes
git diff --staged   # See staged changes
git log -5          # Last 5 commits

# Stashing changes temporarily
git stash           # Save work in progress
git stash pop       # Restore stashed changes

# Updating branches
git fetch origin    # Get latest remote changes
git pull origin <branch>  # Fetch and merge
git rebase origin/<branch>  # Rebase onto latest
```

### Useful Tools

- **GitHub CLI** (gh): Command-line GitHub interface
- **GitLens**: VS Code extension for git integration
- **Pre-commit**: Automate git hooks for linting
- **Husky**: Git hooks made easy (Node.js projects)

### External Documentation

- [GitHub Flow Guide](https://guides.github.com/introduction/flow/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [GitHub Actions Documentation](https://docs.github.com/en/actions)

## Project-Specific Guidelines

### When Adding New Features

1. Create feature branch from main
2. Implement feature with tests
3. Update documentation
4. Create PR with clear description
5. Address code review feedback
6. Merge when approved

### When Fixing Bugs

1. Create bug fix branch
2. Add test that reproduces bug
3. Implement fix
4. Verify test passes
5. Create PR referencing issue
6. Merge when approved

### Code Review Checklist

- [ ] Code follows project style conventions
- [ ] Changes are minimal and focused
- [ ] Tests are included and passing
- [ ] Documentation is updated
- [ ] No security vulnerabilities introduced
- [ ] Performance implications considered
- [ ] Backward compatibility maintained (if applicable)

## Maintenance & Updates

### Regular Tasks

- **Weekly**: Review open PRs and issues
- **Monthly**: Update dependencies, check for security alerts
- **Quarterly**: Archive old issues, review project goals

### Version Management

Follow [Semantic Versioning](https://semver.org/):
- MAJOR: Incompatible API changes
- MINOR: Backward-compatible new features
- PATCH: Backward-compatible bug fixes

Example: v1.2.3
- 1: Major version
- 2: Minor version
- 3: Patch version

## Contact & Support

For questions about:
- **Project structure**: Check this CLAUDE.md document
- **GitHub**: Refer to GitHub documentation
- **Coding issues**: Review code comments and tests
- **Contributions**: Follow the PR process described above

---

**Last Updated**: 2026-07-10  
**Status**: Initial setup  
**Maintainer**: AI Assistant (Claude)
