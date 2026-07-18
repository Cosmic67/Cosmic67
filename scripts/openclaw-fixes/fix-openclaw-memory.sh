#!/bin/bash
# Fix OpenClaw Memory Core issue
# Run this on your local machine

set -e

echo "🔧 OpenClaw Memory Core Fix"
echo "============================"
echo ""

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

OPENCLAW_DIR="$HOME/.openclaw"

# Step 1: Stop the service
echo -e "${YELLOW}1. Stopping OpenClaw gateway...${NC}"
systemctl --user stop openclaw-gateway.service 2>/dev/null || true
sleep 2

# Step 2: Backup configuration
echo -e "${YELLOW}2. Creating backup...${NC}"
if [ -f "$OPENCLAW_DIR/openclaw.json" ]; then
  cp "$OPENCLAW_DIR/openclaw.json" "$OPENCLAW_DIR/openclaw.json.backup-$(date +%s)"
  echo "   ✓ Config backed up"
fi

# Step 3: Remove conflicting legacy memory database
echo -e "${YELLOW}3. Removing conflicting legacy memory index...${NC}"
if [ -f "$OPENCLAW_DIR/memory/main.sqlite" ]; then
  rm -f "$OPENCLAW_DIR/memory/main.sqlite"
  echo "   ✓ Legacy memory/main.sqlite removed"
fi

# Step 4: Clear corrupted agent database
echo -e "${YELLOW}4. Clearing corrupted agent memory database...${NC}"
if [ -f "$OPENCLAW_DIR/agents/main/agent/openclaw-agent.sqlite" ]; then
  # Create a fresh one by removing the old
  rm -f "$OPENCLAW_DIR/agents/main/agent/openclaw-agent.sqlite"
  rm -f "$OPENCLAW_DIR/agents/main/agent/openclaw-agent.sqlite-wal"
  rm -f "$OPENCLAW_DIR/agents/main/agent/openclaw-agent.sqlite-shm"
  echo "   ✓ Agent database cleared"
fi

# Step 5: Clear state migrations cache
echo -e "${YELLOW}5. Clearing state migrations cache...${NC}"
rm -rf "$OPENCLAW_DIR/.migrations-cache" 2>/dev/null || true
echo "   ✓ Cache cleared"

# Step 6: Reset permissions
echo -e "${YELLOW}6. Fixing permissions...${NC}"
chmod 700 "$OPENCLAW_DIR"
chmod -R 700 "$OPENCLAW_DIR/agents" 2>/dev/null || true
echo "   ✓ Permissions fixed"

# Step 7: Restart service
echo -e "${YELLOW}7. Restarting OpenClaw...${NC}"
systemctl --user restart openclaw-gateway.service
sleep 3

# Step 8: Verify
echo -e "${YELLOW}8. Verifying fix...${NC}"
if systemctl --user is-active --quiet openclaw-gateway.service; then
  echo -e "${GREEN}✓ OpenClaw gateway is running!${NC}"
else
  echo -e "${RED}✗ Gateway still not running. Checking logs...${NC}"
  journalctl --user -u openclaw-gateway.service -n 20 --no-pager
  exit 1
fi

echo ""
echo -e "${GREEN}✅ OpenClaw Memory Core fix complete!${NC}"
echo ""
echo "Next steps:"
echo "1. Run: openclaw doctor"
echo "2. Check: systemctl --user status openclaw-gateway.service"
echo ""
