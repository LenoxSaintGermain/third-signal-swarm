#!/bin/bash
#
# Third Signal Swarm — Termux Deploy Script
# Run this in Termux (Ubuntu/proot) after OpenClaw is installed.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/LenoxSaintGermain/third-signal-swarm/main/deploy_swarm.sh | bash
#

set -e

REPO="https://github.com/LenoxSaintGermain/third-signal-swarm.git"
CLONE_DIR="/tmp/third-signal-swarm-deploy"
OPENCLAW_ROOT="$HOME/.openclaw"
SWARM_DEST="$OPENCLAW_ROOT/workspaces/third-signal-swarm"

echo "============================================"
echo "  Third Signal Swarm — Deploy to OpenClaw"
echo "============================================"
echo ""

# --- Step 1: Check git ---
if ! command -v git &> /dev/null; then
    echo "[1/5] Installing git..."
    apt-get update -qq && apt-get install -y -qq git 2>/dev/null || pkg install git -y 2>/dev/null
else
    echo "[1/5] git found."
fi

# --- Step 2: Clone ---
echo "[2/5] Pulling swarm from GitHub..."
rm -rf "$CLONE_DIR"
git clone --depth 1 "$REPO" "$CLONE_DIR"

if [ ! -d "$CLONE_DIR/agents" ]; then
    echo "ERROR: agents directory not found in repo."
    echo "Check https://github.com/LenoxSaintGermain/third-signal-swarm"
    exit 1
fi
echo "  -> Repo pulled."

# --- Step 3: Deploy ---
echo "[3/5] Deploying swarm to $SWARM_DEST..."
mkdir -p "$SWARM_DEST"
cp -r "$CLONE_DIR/agents" "$SWARM_DEST/"
cp "$CLONE_DIR/AGENTS.md" "$SWARM_DEST/" 2>/dev/null || true
echo "  -> Agent workspaces deployed."

# --- Step 4: Config ---
echo "[4/5] Configuring OpenClaw..."
EXISTING_CONFIG="$OPENCLAW_ROOT/openclaw.json"
SWARM_CONFIG="$CLONE_DIR/openclaw.json"

if [ -f "$EXISTING_CONFIG" ]; then
    BACKUP="$OPENCLAW_ROOT/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$EXISTING_CONFIG" "$BACKUP"
    echo "  -> Existing config backed up to: $BACKUP"
    cp "$SWARM_CONFIG" "$OPENCLAW_ROOT/openclaw-swarm-config.json"
    echo "  -> Swarm config saved to: $OPENCLAW_ROOT/openclaw-swarm-config.json"
    echo "  -> Merge into your config or replace:"
    echo "     cp $OPENCLAW_ROOT/openclaw-swarm-config.json $EXISTING_CONFIG"
else
    sed "s|/home/ubuntu/.openclaw|$OPENCLAW_ROOT|g" "$SWARM_CONFIG" > "$EXISTING_CONFIG"
    echo "  -> openclaw.json installed."
fi

# --- Step 5: Verify ---
echo "[5/5] Verifying..."
echo ""

AGENT_COUNT=$(find "$SWARM_DEST/agents" -name "AGENTS.md" -not -empty 2>/dev/null | wc -l)
TEAM_COUNT=$(find "$SWARM_DEST/agents" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

echo "============================================"
echo "  DEPLOYMENT COMPLETE"
echo "============================================"
echo ""
echo "  Agents:  $AGENT_COUNT"
echo "  Teams:   $TEAM_COUNT"
echo "  Path:    $SWARM_DEST"
echo ""
for team_dir in "$SWARM_DEST/agents"/*/; do
    team=$(basename "$team_dir")
    count=$(find "$team_dir" -maxdepth 1 -mindepth 1 -type d | wc -l)
    printf "    %-25s %d agents\n" "$team" "$count"
done
echo ""
echo "  Next: openclaw doctor && openclaw start"
echo "============================================"

rm -rf "$CLONE_DIR"
