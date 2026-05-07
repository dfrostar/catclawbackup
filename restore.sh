#!/bin/bash
# CatClaw Backup & Restore Script
# Recreates the full workspace from this backup + remote repos

set -e

echo "🐱 CatClaw Restore Script"
echo "========================="

# 1. Restore workspace config files
echo ""
echo "📄 Restoring workspace configs..."
cp AGENTS.md MEMORY.md SOUL.md TOOLS.md USER.md IDENTITY.md HEARTBEAT.md README.md ~/.openclaw/workspace/

# 2. Restore skills
echo "🔧 Restoring custom skills..."
cp -r skills/ ~/.openclaw/workspace/skills/

# 3. Restore docs
echo "📚 Restoring docs..."
cp -r docs/ ~/.openclaw/workspace/docs/

# 4. Restore memory
echo "🧠 Restoring memory..."
cp -r memory/ ~/.openclaw/workspace/memory/

# 5. Clone repos
echo ""
echo "📦 Cloning repos..."
cd ~/.openclaw/workspace

echo "  → cmmc20..."
git clone https://github.com/dfrostar/cmmc20.git 2>/dev/null || echo "    (already exists, pulling)"
cd cmmc20 && git pull 2>/dev/null; cd ..

echo "  → Decepticon..."
git clone https://github.com/PurpleAILAB/Decepticon.git 2>/dev/null || echo "    (already exists, pulling)"
cd Decepticon && git pull 2>/dev/null; cd ..

echo "  → mythos-research..."
git clone https://github.com/Keyvanhardani/mythos-research.git 2>/dev/null || echo "    (already exists, pulling)"
cd mythos-research && git pull 2>/dev/null; cd ..

echo "  → autoresearch..."
git clone https://github.com/karpathy/autoresearch.git 2>/dev/null || echo "    (already exists, pulling)"
cd autoresearch && git pull 2>/dev/null; cd ..

echo "  → open-notebook..."
git clone https://github.com/lfnovo/open-notebook.git 2>/dev/null || echo "    (already exists, pulling)"
cd open-notebook && git pull 2>/dev/null; cd ..

echo "  → agency-agents (from Pi)..."
# Copy from backup if Pi is unreachable
if [ ! -d "agency-agents" ]; then
    echo "    ⚠️  agency-agents needs to be fetched from Pi (100.67.32.45) or restored manually"
fi

# 6. Install uv (needed for open-notebook and autoresearch)
echo ""
echo "⚙️  Installing uv..."
curl -LsSf https://astral.sh/uv/install.sh | sh 2>/dev/null || echo "    (already installed)"

# 7. Install SurrealDB v2 (needed for open-notebook)
echo "📦 Installing SurrealDB v2..."
if ! command -v surreal &> /dev/null; then
    cd /tmp
    curl -sL -o surreal-v2.tgz "https://github.com/surrealdb/surrealdb/releases/download/v2.6.5/surreal-v2.6.5.linux-amd64.tgz"
    tar xzf surreal-v2.tgz
    mkdir -p ~/.surrealdb
    mv surreal ~/.surrealdb/
    echo "    SurrealDB installed to ~/.surrealdb/surreal"
fi

# 8. Install open-notebook deps
echo ""
echo "🐍 Installing open-notebook Python deps..."
cd ~/.openclaw/workspace/open-notebook
export PATH="$HOME/.local/bin:$PATH"
uv sync 2>/dev/null || echo "    (uv sync failed — run manually)"

# 9. Start services
echo ""
echo "🚀 Starting services..."
export PATH="/home/node/.surrealdb:$PATH"
nohup surreal start --log warn --user root --pass root --bind 0.0.0.0:8989 memory > /tmp/surreal.log 2>&1 &
echo "    SurrealDB started on :8989"

cd ~/.openclaw/workspace/open-notebook
export PATH="$HOME/.local/bin:$PATH"
OPENAI_COMPATIBLE_API_KEY=${OPENAI_COMPATIBLE_API_KEY:-"SET_ME"} \
OPENAI_COMPATIBLE_BASE_URL=https://integrate.api.nvidia.com/v1 \
nohup uv run python run_api.py > /tmp/open-notebook.log 2>&1 &
echo "    open-notebook API started on :5055"

# 10. Verify
echo ""
echo "✅ Restore complete!"
echo ""
echo "Verify with:"
echo "  curl http://localhost:8989/health  # SurrealDB"
echo "  curl http://localhost:5055/         # open-notebook API"
echo ""
echo "⚠️  Don't forget to set your API keys:"
echo "  export OPENAI_COMPATIBLE_API_KEY=***"
echo "  export ANTHROPIC_API_KEY=***"
echo ""
echo "🐱 CatClaw is back online!"
