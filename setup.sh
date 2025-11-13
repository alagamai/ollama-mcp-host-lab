#!/bin/bash

echo "--------------------------------------"
echo "🧩 MCP Server + Ollama Environment Setup"
echo "--------------------------------------"

PROJECT_ROOT="$(pwd)"
VENV_PATH="$PROJECT_ROOT/.mcp_env"
CONFIG_PATH="$PROJECT_ROOT/local.json"
GO_BIN="$(go env GOPATH)/bin"
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$LOG_DIR"

echo "📁 Project root: $PROJECT_ROOT"
echo "🪣 Logs stored in: $LOG_DIR"


# ----------------------------------------------------
# 1️⃣ Create/Activate Python Virtual Environment
# ----------------------------------------------------
if [ ! -d "$VENV_PATH" ]; then
    echo "🧱 Creating virtual environment (.mcp_env)..."
    python3 -m venv "$VENV_PATH"
else
    echo "✅ Virtual environment already exists."
fi

echo "📦 Activating environment..."
source "$VENV_PATH/bin/activate"


# ----------------------------------------------------
# 2️⃣ Verify/Install Go
# ----------------------------------------------------
if ! command -v go &>/dev/null; then
  echo "📦 Installing Go..."
  brew install go
else
  echo "✅ Go found: $(go version)"
fi

export PATH="$PATH:$(go env GOPATH)/bin"
echo "📁 GOPATH: $(go env GOPATH)"


# ----------------------------------------------------
# 3️⃣ Verify/Install Ollama
# ----------------------------------------------------
echo "🔍 Checking for Ollama..."
if ! command -v ollama &>/dev/null; then
    echo "⚙️ Ollama not found. Installing via Homebrew..."
    brew install ollama
else
    echo "✅ Ollama is already installed."
fi


# ----------------------------------------------------
# 4️⃣ Stop old Ollama and MCPHost instances
# ----------------------------------------------------
echo "🧹 Cleaning up old processes..."

OLD_OLLAMA_PID=$(lsof -ti tcp:11434)
if [ ! -z "$OLD_OLLAMA_PID" ]; then
    echo "🛑 Stopping old Ollama server..."
    kill -9 "$OLD_OLLAMA_PID"
fi

OLD_MCP_PID=$(pgrep -f mcphost)
if [ ! -z "$OLD_MCP_PID" ]; then
    echo "🛑 Stopping old MCPHost process..."
    kill -9 "$OLD_MCP_PID"
fi


# ----------------------------------------------------
# 5️⃣ Start Ollama Server (Background)
# ----------------------------------------------------
echo "🚀 Starting Ollama server..."
ollama serve > "$LOG_DIR/ollama.log" 2>&1 &

echo "⏳ Waiting for Ollama to start..."
sleep 3

if curl -s http://localhost:11434/api/tags >/dev/null; then
    echo "✅ Ollama server is running."
else
    echo "❌ ERROR: Ollama failed to start."
    echo "👉 Check logs: $LOG_DIR/ollama.log"
    exit 1
fi


# ----------------------------------------------------
# 6️⃣ Python Dependencies
# ----------------------------------------------------
echo "📦 Installing Python dependencies..."
pip install --upgrade pip


# ----------------------------------------------------
# 7️⃣ Pull Required Ollama Model
# ----------------------------------------------------
echo "📥 Pulling qwen2.5 model..."
ollama pull qwen2.5


# ----------------------------------------------------
# 8️⃣ Install MCPHost & Start It (Background)
# ----------------------------------------------------
echo "⚙️ Installing MCPHost..."
go install github.com/mark3labs/mcphost@latest

if [ ! -f "$GO_BIN/mcphost" ]; then
    echo "❌ MCPHost installation failed."
    exit 1
fi


#echo "🚀 Starting MCPHost (background)..."
#"$GO_BIN/mcphost" -m ollama:qwen2.5 --config "$CONFIG_PATH" > "$LOG_DIR/mcphost.log" 2>&1 &

export LOG_LEVEL=error

# ----------------------------------------------------
# 🧠 Create handy aliases for MCPHost control
# ----------------------------------------------------
echo "⚙️  Adding MCP aliases to ~/.zshrc ..."

# Avoid duplicate alias lines
if ! grep -q "alias mcpstart=" ~/.zshrc 2>/dev/null; then
  echo "alias mcpstart='/Users/alagammainagappan/go/bin/mcphost -m ollama:qwen2.5 --config /Users/alagammainagappan/PycharmProjects/mcp-server/local.json'" >> ~/.zshrc
  echo "alias mcpquiet='/Users/alagammainagappan/go/bin/mcphost -m ollama:qwen2.5 --config /Users/alagammainagappan/PycharmProjects/mcp-server/local.json > /Users/alagammainagappan/PycharmProjects/mcp-server/logs/mcphost.log 2>&1 &'" >> ~/.zshrc
  echo "alias mcpstop='pkill -f mcphost'" >> ~/.zshrc
  echo "alias mcplogs='tail -f /Users/alagammainagappan/PycharmProjects/mcp-server/logs/mcphost.log'" >> ~/.zshrc
  echo "✅ Aliases added: mcpstart, mcpquiet, mcpstop, mcplogs"
else
  echo "ℹ️ MCP aliases already exist in ~/.zshrc"
fi

source ~/.zshrc

# mcp-server % /Users/alagammainagappan/go/bin/mcphost -m ollama:qwen2.5 --config ./local.json



# ----------------------------------------------------
# 9️⃣ Health Check
# ----------------------------------------------------

echo "🎯 Setup completed successfully!"
echo "✅ Environment ready and running."
echo "📄 Ollama log: $LOG_DIR/ollama.log"
echo "📄 MCPHost log: $LOG_DIR/mcphost.log"

