# OpenClaw Memory Core Fixes

This directory contains scripts to repair OpenClaw's memory core issues, which often manifest as database corruption or state migration errors.

## Problem Description

OpenClaw may encounter memory core issues when:
- Legacy memory database files conflict with the new agent-based architecture
- State migration cache becomes corrupted
- Session cache causes initialization failures
- Agent database files become corrupted or locked

## Available Fix Scripts

### 1. `fix-openclaw-memory.sh` - Basic Local Fix
**Use this for:** Standard OpenClaw installations running on your local machine

**What it does:**
- Stops the OpenClaw gateway service
- Backs up the current configuration
- Removes legacy memory database files
- Clears corrupted agent memory database
- Removes state migration cache
- Resets directory permissions
- Restarts the OpenClaw gateway
- Verifies the fix

**How to use:**
```bash
bash scripts/openclaw-fixes/fix-openclaw-memory.sh
```

### 2. `fix-openclaw-complete.sh` - Comprehensive Local Fix
**Use this for:** More thorough repairs with additional system checks

**What it does:**
- All steps from basic fix plus:
- Clears session cache
- Runs comprehensive directory permission fixes
- Validates OpenClaw command availability
- Runs `openclaw doctor` for diagnostics
- Provides detailed verification and next steps

**How to use:**
```bash
bash scripts/openclaw-fixes/fix-openclaw-complete.sh
```

### 3. `fix-openclaw-docker.sh` - Docker Container Fix
**Use this for:** OpenClaw running in a Docker container

**What it does:**
- Finds the OpenClaw Docker container
- Backs up configuration files
- Removes corrupted memory and agent databases
- Clears migration and session caches
- Restarts the container
- Verifies container is running

**How to use:**
```bash
bash scripts/openclaw-fixes/fix-openclaw-docker.sh
```

## Which Script to Use?

1. **Docker container?** → Use `fix-openclaw-docker.sh`
2. **Local installation, simple fix needed?** → Use `fix-openclaw-memory.sh`
3. **Local installation, comprehensive fix needed?** → Use `fix-openclaw-complete.sh`

## After Running a Fix

1. Wait 10 seconds for full initialization
2. Run: `openclaw doctor`
3. Check service status:
   - **Local:** `systemctl --user status openclaw-gateway.service`
   - **Docker:** `docker ps | grep openclaw`

## Common Issues and Solutions

**Issue: "OpenClaw not found"**
- Ensure OpenClaw is installed in `~/.openclaw`
- For Docker, verify container exists and is named with "openclaw"

**Issue: "Permission denied"**
- Run with `sudo` if necessary
- Ensure you have write access to `~/.openclaw` or the container

**Issue: Gateway fails to start**
- Check logs:
  - **Local:** `journalctl --user -u openclaw-gateway.service -n 30`
  - **Docker:** `docker logs <container-id>`
- Run the comprehensive fix: `fix-openclaw-complete.sh`

## Backup Location

Configuration backups are created at:
- **Local:** `~/.openclaw/backups/openclaw.json.<timestamp>`
- **Docker:** `/tmp/openclaw-backup-<timestamp>/`

## Safety Notes

- These scripts back up your configuration before making changes
- The fixes only remove database and cache files, not configuration
- Your OpenClaw configuration and settings are preserved
- All changes are reversible by restoring from the backup

## Troubleshooting

If the fix doesn't resolve your issue:

1. Check the OpenClaw logs for specific error messages
2. Ensure you have sufficient disk space
3. Verify OpenClaw was properly installed
4. Try the comprehensive fix if the basic fix didn't work
5. Restore from backup if needed and investigate further

## Support

For more information about OpenClaw:
- Official documentation: https://openclaw.ai
- GitHub repository: https://github.com/openclaw/openclaw
