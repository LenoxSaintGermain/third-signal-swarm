#!/bin/bash
#
# Third Signal Swarm — Termux Deploy Script
# Run this in Termux (Ubuntu/proot) after OpenClaw is installed.
#
# Usage:
#   curl -sL https://raw.githubusercontent.com/LenoxSaintGermain/orbital-system/main/openclaw-swarm/deploy_swarm.sh | bash
#   — or —
#   bash deploy_swarm.sh
#

set -e

# --- Config ---
REPO="https://github.com/LenoxSaintGermain/orbital-system.git"
CLONE_DIR="/tmp/orbital-system-deploy"
OPENCLAW_ROOT="$HOME/.openclaw"
SWARM_DEST="$OPENCLAW_ROOT/workspaces/third-signal-swarm"

echo "============================================"
echo "  Third Signal Swarm — Deploy to OpenClaw"
echo "============================================"
echo ""

# --- Step 1: Install git if missing ---
if ! command -v git &> /dev/null; then
    echo "[1/5] Installing git..."
    apt-get update -qq && apt-get install -y -qq git
else
    echo "[1/5] git found."
fi

# --- Step 2: Clone the repo (sparse checkout for speed) ---
echo "[2/5] Pulling swarm from GitHub..."
rm -rf "$CLONE_DIR"

# Try sparse checkout first (faster), fall back to full clone
if git clone --depth 1 --filter=blob:none --sparse "$REPO" "$CLONE_DIR" 2>/dev/null; then
    cd "$CLONE_DIR"
    git sparse-checkout set openclaw-swarm 2>/dev/null || true
else
    echo "  -> Sparse checkout not supported, doing full clone..."
    git clone --depth 1 "$REPO" "$CLONE_DIR"
    cd "$CLONE_DIR"
fi

# Verify the swarm directory exists
if [ ! -d "$CLONE_DIR/openclaw-swarm" ]; then
    echo "ERROR: openclaw-swarm directory not found in repo."
    echo "Check https://github.com/LenoxSaintGermain/orbital-system"
    exit 1
fi

echo "  -> Repo pulled successfully."

# --- Step 3: Deploy the swarm workspace ---
echo "[3/5] Deploying swarm to $SWARM_DEST..."
mkdir -p "$SWARM_DEST"

# Copy all agent workspaces (preserve structure)
cp -r "$CLONE_DIR/openclaw-swarm/agents" "$SWARM_DEST/"
cp -r "$CLONE_DIR/openclaw-swarm/AGENTS.md" "$SWARM_DEST/" 2>/dev/null || true

echo "  -> Agent workspaces deployed."

# --- Step 4: Merge or install openclaw.json ---
echo "[4/5] Configuring OpenClaw..."

EXISTING_CONFIG="$OPENCLAW_ROOT/openclaw.json"
SWARM_CONFIG="$CLONE_DIR/openclaw-swarm/openclaw.json"

if [ -f "$EXISTING_CONFIG" ]; then
    # Back up existing config
    BACKUP="$OPENCLAW_ROOT/openclaw.json.backup.$(date +%Y%m%d_%H%M%S)"
    cp "$EXISTING_CONFIG" "$BACKUP"
    echo "  -> Existing config backed up to: $BACKUP"
    echo ""
    echo "  IMPORTANT: Your existing openclaw.json was preserved."
    echo "  The swarm config has been saved to:"
    echo "    $OPENCLAW_ROOT/openclaw-swarm-config.json"
    echo ""
    echo "  To use the swarm agents, merge the 'agents.list' array"
    echo "  from the swarm config into your existing config, or replace it:"
    echo "    cp $OPENCLAW_ROOT/openclaw-swarm-config.json $EXISTING_CONFIG"
    echo ""
    cp "$SWARM_CONFIG" "$OPENCLAW_ROOT/openclaw-swarm-config.json"
else
    # No existing config — install the swarm config directly
    # Fix workspace paths to use $HOME instead of hardcoded paths
    sed "s|/home/ubuntu/.openclaw|$OPENCLAW_ROOT|g" "$SWARM_CONFIG" > "$EXISTING_CONFIG"
    echo "  -> openclaw.json installed."
fi

# --- Step 5: Verify and report ---
echo "[5/5] Verifying deployment..."
echo ""

AGENT_COUNT=$(find "$SWARM_DEST/agents" -name "AGENTS.md" -not -empty 2>/dev/null | wc -l)
TEAM_COUNT=$(find "$SWARM_DEST/agents" -mindepth 1 -maxdepth 1 -type d 2>/dev/null | wc -l)

echo "============================================"
echo "  DEPLOYMENT COMPLETE"
echo "============================================"
echo ""
echo "  Agents deployed:  $AGENT_COUNT"
echo "  Teams deployed:   $TEAM_COUNT"
echo "  Swarm workspace:  $SWARM_DEST"
echo "  OpenClaw config:  $EXISTING_CONFIG"
echo ""
echo "  Teams:"
for team_dir in "$SWARM_DEST/agents"/*/; do
    team=$(basename "$team_dir")
    count=$(find "$team_dir" -maxdepth 1 -mindepth 1 -type d | wc -l)
    printf "    %-25s %d agents\n" "$team" "$count"
done
echo ""
echo "  Next steps:"
echo "    1. Review/merge openclaw.json if you had an existing config"
echo "    2. Run: openclaw doctor        (verify health)"
echo "    3. Run: openclaw start         (launch the swarm)"
echo ""
echo "  To update later, just re-run this script."
echo "============================================"

# --- Cleanup ---
rm -rf "$CLONE_DIR"
