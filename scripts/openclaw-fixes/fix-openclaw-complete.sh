#!/bin/bash
# 🔧 OpenClaw Memory Core Complete Fix
# Execute this script on your local machine to repair OpenClaw

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║         OpenClaw Memory Core Fix - Complete            ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

OPENCLAW_DIR="$HOME/.openclaw"

# Check if OpenClaw exists
if [ ! -d "$OPENCLAW_DIR" ]; then
  echo -e "${RED}✗ OpenClaw not found at $OPENCLAW_DIR${NC}"
  exit 1
fi

echo ""
echo -e "${YELLOW}Step 1: Stopping OpenClaw Gateway...${NC}"
systemctl --user stop openclaw-gateway.service 2>/dev/null || true
sleep 3
echo -e "${GREEN}✓ Stopped${NC}"

echo ""
echo -e "${YELLOW}Step 2: Backing up configuration...${NC}"
BACKUP_DIR="$OPENCLAW_DIR/backups"
mkdir -p "$BACKUP_DIR"
TIMESTAMP=$(date +%Y%m%d_%H%M%S)

if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
  cp "$OPENCLAW_DIR/openclaw.json" "$BACKUP_DIR/openclaw.json.$TIMESTAMP"
  echo -e "${GREEN}✓ Config backed up to $BACKUP_DIR/openclaw.json.$TIMESTAMP${NC}"
fi

echo ""
echo -e "${YELLOW}Step 3: Removing corrupted legacy memory database...${NC}"
REMOVED=0

if [ -f "$OPENCLAW_DIR/memory/main.sqlite" ]; then
  rm -f "$OPENCLAW_DIR/memory/main.sqlite"
  echo -e "${GREEN}✓ Removed legacy memory/main.sqlite${NC}"
  REMOVED=$((REMOVED+1))
fi

if [ -d "$OPENCLAW_DIR/memory" ] && [ -z "$(ls -A "$OPENCLAW_DIR/memory")" ]; then
  rmdir "$OPENCLAW_DIR/memory"
  echo -e "${GREEN}✓ Removed empty memory directory${NC}"
fi

echo ""
echo -e "${YELLOW}Step 4: Clearing agent memory database...${NC}"
AGENT_DB="$OPENCLAW_DIR/agents/main/agent/openclaw-agent.sqlite"
if [ -f "$AGENT_DB" ]; then
  rm -f "$AGENT_DB" "$AGENT_DB-wal" "$AGENT_DB-shm"
  echo -e "${GREEN}✓ Cleared agent database${NC}"
  REMOVED=$((REMOVED+1))
fi

echo ""
echo -e "${YELLOW}Step 5: Removing state migration cache...${NC}"
rm -rf "$OPENCLAW_DIR/.migrations-cache" 2>/dev/null || true
echo -e "${GREEN}✓ Cache cleared${NC}"

echo ""
echo -e "${YELLOW}Step 6: Clearing session cache...${NC}"
rm -rf "$OPENCLAW_DIR/agents/main/sessions/.cache" 2>/dev/null || true
echo -e "${GREEN}✓ Session cache cleared${NC}"

echo ""
echo -e "${YELLOW}Step 7: Fixing directory permissions...${NC}"
chmod 700 "$OPENCLAW_DIR"
chmod -R 700 "$OPENCLAW_DIR/agents" 2>/dev/null || true
echo -e "${GREEN}✓ Permissions fixed${NC}"

echo ""
echo -e "${YELLOW}Step 8: Starting OpenClaw Gateway...${NC}"
systemctl --user start openclaw-gateway.service
sleep 4

if systemctl --user is-active --quiet openclaw-gateway.service; then
  echo -e "${GREEN}✓ Gateway started successfully${NC}"
else
  echo -e "${RED}✗ Gateway failed to start. Checking logs...${NC}"
  echo ""
  journalctl --user -u openclaw-gateway.service -n 30 --no-pager
  exit 1
fi

echo ""
echo -e "${YELLOW}Step 9: Verifying OpenClaw status...${NC}"
sleep 2

# Try to run openclaw doctor
if command -v openclaw &> /dev/null; then
  echo -e "${GREEN}✓ OpenClaw command found${NC}"
  echo ""
  echo -e "${BLUE}Running openclaw doctor...${NC}"
  openclaw doctor 2>&1 | head -50
else
  echo -e "${YELLOW}⚠ openclaw command not found in PATH${NC}"
  echo "   Trying to use full path..."
  find "$HOME" -name "openclaw" -type f 2>/dev/null | head -1 || true
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗"
echo "║                ✅ FIX COMPLETE!                         ║"
echo "╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "Summary:"
echo "  - Removed $REMOVED corrupted database files"
echo "  - Cleared caches and migration state"
echo "  - Restarted OpenClaw Gateway"
echo "  - Gateway status: $(systemctl --user is-active openclaw-gateway.service)"
echo ""
echo "Next steps:"
echo "  1. Wait 10 seconds for full initialization"
echo "  2. Run: openclaw doctor"
echo "  3. Check: systemctl --user status openclaw-gateway.service"
echo ""
