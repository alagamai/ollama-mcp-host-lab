#!/bin/bash

echo "--------------------------------------"
echo "🧩 Activating MCP server  Virtual Environment"
echo "--------------------------------------"

PROJECT_ROOT="$(pwd)"
VENV_PATH="$PROJECT_ROOT/.mcp_env"

# Create the virtual environment if missing
if [ ! -d "$VENV_PATH" ]; then
    echo "⚙️ No virtual environment found. Creating one at:"
    echo "   $VENV_PATH"
    python3 -m venv "$VENV_PATH"
    echo "✅ Virtual environment created."
fi

# Activate environment
echo "🔹 Activating environment at: $VENV_PATH"
source "$VENV_PATH/bin/activate"

echo "✅ Environment activated."
echo "Virtual Env: $VENV_PATH"
echo "--------------------------------------"
echo "Next:"
echo "  Run:  ./setup.sh"
echo "--------------------------------------"

