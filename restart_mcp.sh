#!/bin/bash

echo "--------------------------------------"
echo "♻️ Restarting Ollama + MCPHost Environment"
echo "--------------------------------------"

PROJECT_ROOT="$(pwd)"
CONFIG_PATH="$PROJECT_ROOT/local.json"
GO_BIN="$(go env GOPATH)/bin"
LOG_DIR="$PROJECT_ROOT/logs"

mkdir -p "$LOG_DIR"

echo "📁 Project root: $PROJECT_ROOT"
echo "🪣 Logs directory: $LOG_DIR"

# ----------------------------------------------------
# 1️⃣ Stop existing processes
# ----------------------------------------------------
echo "🛑 Stopping old processes..."

if pgrep -f mcphost >/dev/null; then
    echo "🧹 Killing old MCPHost..."
    pkill -f mcphost
fi

if pgrep -f ollama >/dev/null; then
    echo "🧹 Killing old Ollama server..."
    pkill ollama
fi

sleep 2
echo "✅ All old processes stopped."

# ----------------------------------------------------
# 2️⃣ Verify Ollama installation
# ----------------------------------------------------
if ! command -v ollama &>/dev/null; then
    echo "❌ Ollama not installed. Please install with:"
    echo "brew install ollama"
    exit 1
fi

# ----------------------------------------------------
# 3️⃣ Clean up leftover runners (if any)
# ----------------------------------------------------
echo "🧽 Cleaning up stale runners..."
RUNNING_MODELS=$(ollama ps | awk 'NR>1 {print $1}')
if [ -n "$RUNNING_MODELS" ]; then
    for model in $RUNNING_MODELS; do
        echo "🛑 Stopping model: $model"
        ollama stop "$model"
    done
else
    echo "✅ No running models to stop."
fi

# ----------------------------------------------------
# 4️⃣ Start Ollama server
# ----------------------------------------------------
echo "🚀 Starting Ollama server..."
ollama serve > "$LOG_DIR/ollama.log" 2>&1 &

sleep 3

if curl -s http://localhost:11434/api/tags >/dev/null; then
    echo "✅ Ollama server is running on port 11434"
else
    echo "❌ ERROR: Ollama server failed to start. Check logs:"
    echo "👉 $LOG_DIR/ollama.log"
    exit 1
fi

# ----------------------------------------------------
# 5️⃣ Start MCPHost
# ----------------------------------------------------
if [ ! -f "$CONFIG_PATH" ]; then
    echo "❌ Config file not found at: $CONFIG_PATH"
    exit 1
fi

if [ ! -f "$GO_BIN/mcphost" ]; then
    echo "⚙️ Installing MCPHost..."
    go install github.com/mark3labs/mcphost@latest
fi

echo "🚀 Starting MCPHost..."
"$GO_BIN/mcphost" -m ollama:qwen2.5 --config "$CONFIG_PATH" > "$LOG_DIR/mcphost.log" 2>&1 &

sleep 2

if pgrep -f mcphost >/dev/null; then
    echo "✅ MCPHost is running successfully."
else
    echo "❌ MCPHost failed to start. Check logs:"
    echo "👉 $LOG_DIR/mcphost.log"
    exit 1
fi

# ----------------------------------------------------
# 6️⃣ Show summary
# ----------------------------------------------------
echo "--------------------------------------"
echo "🎯 Restart complete!"
echo "✅ Ollama + MCPHost running in background."
echo "📄 Ollama log:   $LOG_DIR/ollama.log"
echo "📄 MCPHost log:  $LOG_DIR/mcphost.log"
echo "--------------------------------------"


