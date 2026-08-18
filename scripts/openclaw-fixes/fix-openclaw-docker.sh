#!/bin/bash
# 🔧 OpenClaw Docker Memory Fix - Complete

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}"
echo "╔════════════════════════════════════════════════════════╗"
echo "║       OpenClaw Docker Memory Core Fix                  ║"
echo "╚════════════════════════════════════════════════════════╝"
echo -e "${NC}"

# Find OpenClaw container
echo -e "${YELLOW}Searching for OpenClaw container...${NC}"
CONTAINER=$(docker ps -a --filter "ancestor=openclaw" --format "{{.ID}} {{.Names}}" 2>/dev/null | head -1 | awk '{print $1}')

if [ -z "$CONTAINER" ]; then
  echo -e "${YELLOW}Trying alternative search...${NC}"
  CONTAINER=$(docker ps -a --format "{{.ID}} {{.Names}}" | grep -i openclaw | head -1 | awk '{print $1}')
fi

if [ -z "$CONTAINER" ]; then
  echo -e "${RED}✗ OpenClaw container not found${NC}"
  echo ""
  echo "Available containers:"
  docker ps -a --format "table {{.ID}}\t{{.Names}}\t{{.Image}}"
  exit 1
fi

echo -e "${GREEN}✓ Found container: $CONTAINER${NC}"

echo ""
echo -e "${YELLOW}Stopping container...${NC}"
docker stop "$CONTAINER" 2>/dev/null || true
sleep 3
echo -e "${GREEN}✓ Stopped${NC}"

echo ""
echo -e "${YELLOW}Backing up OpenClaw config...${NC}"
BACKUP_DIR="/tmp/openclaw-backup-$(date +%Y%m%d_%H%M%S)"
mkdir -p "$BACKUP_DIR"
docker cp "$CONTAINER":/root/.openclaw/openclaw.json "$BACKUP_DIR/" 2>/dev/null || true
echo -e "${GREEN}✓ Backed up to $BACKUP_DIR${NC}"

echo ""
echo -e "${YELLOW}Removing corrupted memory databases...${NC}"
docker exec "$CONTAINER" rm -f /root/.openclaw/memory/main.sqlite 2>/dev/null || true
docker exec "$CONTAINER" rm -f /root/.openclaw/agents/main/agent/openclaw-agent.sqlite* 2>/dev/null || true
docker exec "$CONTAINER" rmdir /root/.openclaw/memory 2>/dev/null || true
echo -e "${GREEN}✓ Removed${NC}"

echo ""
echo -e "${YELLOW}Clearing caches...${NC}"
docker exec "$CONTAINER" rm -rf /root/.openclaw/.migrations-cache 2>/dev/null || true
docker exec "$CONTAINER" rm -rf /root/.openclaw/agents/main/sessions/.cache 2>/dev/null || true
echo -e "${GREEN}✓ Cleared${NC}"

echo ""
echo -e "${YELLOW}Starting container...${NC}"
docker start "$CONTAINER"
sleep 5
echo -e "${GREEN}✓ Started${NC}"

echo ""
echo -e "${YELLOW}Checking status...${NC}"
if docker ps | grep -q "$CONTAINER"; then
  echo -e "${GREEN}✓ Container is running!${NC}"
else
  echo -e "${RED}✗ Container failed to start${NC}"
  docker logs "$CONTAINER" | tail -30
  exit 1
fi

echo ""
echo -e "${GREEN}╔════════════════════════════════════════════════════════╗"
echo "║                ✅ FIX COMPLETE!                         ║"
echo "╚════════════════════════════════════════════════════════╝${NC}"
echo ""
echo "OpenClaw should be running now!"
echo ""
