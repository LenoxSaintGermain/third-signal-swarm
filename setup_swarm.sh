#!/bin/bash
#
# Third Signal Swarm: OpenClaw Agent Architecture Bootstrap
#
# This script scaffolds a multi-agent swarm architecture for OpenClaw,
# tailored to the Third Signal venture studio context.
#

set -e

# --- Configuration ---
# The root directory for all OpenClaw configurations and workspaces.
# Using a variable makes it easy to change the install path.
OPENCLAW_ROOT="$HOME/.openclaw"
SWARM_WORKSPACE="$OPENCLAW_ROOT/workspaces/third-signal-swarm"

echo "Bootstrapping Third Signal Swarm in $SWARM_WORKSPACE..."

# --- Master Workspace & Config ---
# Create the master workspace and the main OpenClaw config file.

mkdir -p "$SWARM_WORKSPACE"
mkdir -p "$OPENCLAW_ROOT/credentials"

# Create the master openclaw.json. This is the central nervous system.
# It defines all agents and their individual workspaces.
cat << EOF > "$OPENCLAW_ROOT/openclaw.json"
{
  // Third Signal Swarm Configuration
  "agents": {
    "defaults": {
      "model": {
        "primary": "anthropic/claude-3-opus-20240229",
        "fallbacks": ["openai/gpt-4o"]
      },
      "userTimezone": "America/New_York"
    },
    "list": [
      // --- Engineering Team ---
      { "id": "frontend-developer", "workspace": "$SWARM_WORKSPACE/agents/engineering/frontend-developer" },
      { "id": "backend-architect", "workspace": "$SWARM_WORKSPACE/agents/engineering/backend-architect" },
      { "id": "mobile-app-builder", "workspace": "$SWARM_WORKSPACE/agents/engineering/mobile-app-builder" },
      { "id": "ai-engineer", "workspace": "$SWARM_WORKSPACE/agents/engineering/ai-engineer" },
      { "id": "devops-automator", "workspace": "$SWARM_WORKSPACE/agents/engineering/devops-automator" },
      { "id": "rapid-prototyper", "workspace": "$SWARM_WORKSPACE/agents/engineering/rapid-prototyper" },

      // --- Product Team ---
      { "id": "trend-researcher", "workspace": "$SWARM_WORKSPACE/agents/product/trend-researcher" },
      { "id": "feedback-synthesizer", "workspace": "$SWARM_WORKSPACE/agents/product/feedback-synthesizer" },
      { "id": "sprint-prioritizer", "workspace": "$SWARM_WORKSPACE/agents/product/sprint-prioritizer" },

      // --- Marketing Team ---
      { "id": "tiktok-strategist", "workspace": "$SWARM_WORKSPACE/agents/marketing/tiktok-strategist" },
      { "id": "instagram-curator", "workspace": "$SWARM_WORKSPACE/agents/marketing/instagram-curator" },
      { "id": "twitter-engager", "workspace": "$SWARM_WORKSPACE/agents/marketing/twitter-engager" },
      { "id": "reddit-community-builder", "workspace": "$SWARM_WORKSPACE/agents/marketing/reddit-community-builder" },
      { "id": "app-store-optimizer", "workspace": "$SWARM_WORKSPACE/agents/marketing/app-store-optimizer" },
      { "id": "content-creator", "workspace": "$SWARM_WORKSPACE/agents/marketing/content-creator" },
      { "id": "growth-hacker", "workspace": "$SWARM_WORKSPACE/agents/marketing/growth-hacker" },

      // --- Design Team ---
      { "id": "ui-designer", "workspace": "$SWARM_WORKSPACE/agents/design/ui-designer" },
      { "id": "ux-researcher", "workspace": "$SWARM_WORKSPACE/agents/design/ux-researcher" },
      { "id": "brand-guardian", "workspace": "$SWARM_WORKSPACE/agents/design/brand-guardian" },
      { "id": "visual-storyteller", "workspace": "$SWARM_WORKSPACE/agents/design/visual-storyteller" },
      { "id": "whimsy-injector", "workspace": "$SWARM_WORKSPACE/agents/design/whimsy-injector" },

      // --- Project Management ---
      { "id": "experiment-tracker", "workspace": "$SWARM_WORKSPACE/agents/project-management/experiment-tracker" },
      { "id": "project-shipper", "workspace": "$SWARM_WORKSPACE/agents/project-management/project-shipper" },
      { "id": "studio-producer", "workspace": "$SWARM_WORKSPACE/agents/project-management/studio-producer" },

      // --- Studio Operations ---
      { "id": "support-responder", "workspace": "$SWARM_WORKSPACE/agents/studio-operations/support-responder" },
      { "id": "analytics-reporter", "workspace": "$SWARM_WORKSPACE/agents/studio-operations/analytics-reporter" },
      { "id": "infrastructure-maintainer", "workspace": "$SWARM_WORKSPACE/agents/studio-operations/infrastructure-maintainer" },
      { "id": "legal-compliance-checker", "workspace": "$SWARM_WORKSPACE/agents/studio-operations/legal-compliance-checker" },
      { "id": "finance-tracker", "workspace": "$SWARM_WORKSPACE/agents/studio-operations/finance-tracker" },

      // --- Testing ---
      { "id": "tool-evaluator", "workspace": "$SWARM_WORKSPACE/agents/testing/tool-evaluator" },
      { "id": "api-tester", "workspace": "$SWARM_WORKSPACE/agents/testing/api-tester" },
      { "id": "workflow-optimizer", "workspace": "$SWARM_WORKSPACE/agents/testing/workflow-optimizer" },
      { "id": "performance-benchmarker", "workspace": "$SWARM_WORKSPACE/agents/testing/performance-benchmarker" },
      { "id": "test-results-analyzer", "workspace": "$SWARM_WORKSPACE/agents/testing/test-results-analyzer" }
    ]
  }
}
EOF

# Create the master AGENTS.md file for the orchestrator.
cat << EOF > "$SWARM_WORKSPACE/AGENTS.md"
# Orchestrator: Third Signal Swarm

This is the master orchestrator for the Third Signal Swarm. My primary role is to route incoming tasks to the appropriate specialist agent or team. I maintain the overall strategic context of the venture studio (GFS, Orbital, AfterHours, Saint & Summer) and ensure that all agent actions align with the "Systems, not Tasks" doctrine.

## Agent Teams

- **/engineering**: Builds the products. Frontend, backend, mobile, AI, and DevOps.
- **/product**: Defines what to build. Researches trends, synthesizes feedback, and prioritizes the roadmap.
- **/marketing**: Grows the audience. Manages social channels, content, and growth experiments.
- **/design**: Defines the user experience. UI, UX, brand, and visual storytelling.
- **/project-management**: Ships the projects. Tracks experiments, manages timelines, and produces studio output.
- **/studio-operations**: Runs the business. Support, analytics, infrastructure, legal, and finance.
- **/testing**: Ensures quality. Evaluates tools, tests APIs, and optimizes workflows.

When a task comes in, I will first classify its domain and then delegate it to the lead agent of the corresponding team. For example, a request to "design a new landing page" will be routed to the `ui-designer`.
EOF

# --- Agent Workspace Scaffolding ---
# This function creates a dedicated workspace for a single agent.

scaffold_agent() {
    AGENT_PATH="$SWARM_WORKSPACE/agents/$1"
    AGENT_NAME=$(basename "$AGENT_PATH")
    TEAM_NAME=$(basename "$(dirname "$AGENT_PATH")")

    mkdir -p "$AGENT_PATH/memory"

    # Create the agent-specific AGENTS.md file, which defines its role.
    # The content will be written in the next phase.
    touch "$AGENT_PATH/AGENTS.md"

    # Create a default SOUL.md for consistent persona.
    cat << EOF > "$AGENT_PATH/SOUL.md"
# Persona

You are a specialist AI agent within the Third Signal Swarm. You are hyper-competent, concise, and biased toward action. You operate with the full context of Lenox Saint Germain's ventures (Orbital, AfterHours, Saint & Summer) and his enterprise AI work at GFS. Your communication style is high-signal, low-friction. You think in terms of systems, leverage, and compound value.
EOF

    # Create a default USER.md.
    cat << EOF > "$AGENT_PATH/USER.md"
# User Profile

The user is Lenox Saint Germain. He is a GenAI Product Strategist, AI Solutions Architect, and Venture Operator. He values first-principles thinking, contrarian insights, and rapid execution. Address him directly as Lenox. Assume high technical literacy.
EOF

    echo "  -> Scaffolded agent: $TEAM_NAME/$AGENT_NAME"
}

# --- Build the Swarm ---

TEAMS="engineering product marketing design project-management studio-operations testing"

for team in $TEAMS; do
    echo "[+] Building Team: $team"
    AGENTS=$(grep -oP "(?<=$team/)[^\" ]+" "$OPENCLAW_ROOT/openclaw.json")
    for agent_id in $AGENTS; do
        scaffold_agent "$team/$agent_id"
    done
done

echo "\nThird Signal Swarm structure created successfully."
echo "Master config: $OPENCLAW_ROOT/openclaw.json"
echo "Master workspace: $SWARM_WORKSPACE"
