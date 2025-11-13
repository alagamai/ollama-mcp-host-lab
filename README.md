# 🧩 MCP Host + Ollama (Qwen) Demo

> **Demo showing how to connect MCPHost and MCP servers with a local LLM (Ollama Qwen).**  
> This setup demonstrates how a local AI runtime can integrate Filesystem, SQLite, GitHub, Playwright, and DuckDuckGo MCP servers to automate tasks through the Model Context Protocol (MCP).

🧠 Architecture
                 ┌────────────────────┐
                 │   Ollama (Qwen)    │
                 │ Local LLM Runtime  │
                 └─────────┬──────────┘
                           │
                 [Model Context Protocol]
                           │
        ┌──────────┬──────────┬──────────┬──────────┐
        │ Filesystem│ SQLite  │ GitHub   │ Playwright│
        │ MCP       │ MCP     │ MCP      │ MCP       │
        └───────────┴─────────┴──────────┴───────────┘
                           │
                  Logs and Local Context


---

## 🚀 Overview

This project is a **hands-on demo** that connects:

- 🧠 **Ollama (Qwen model)** — local LLM engine  
- 🧩 **MCPHost** — the protocol orchestrator  
- ⚙️ **MCP Servers** — external tools that provide capabilities such as:
  - **Filesystem access**
  - **SQLite database queries**
  - **GitHub integration**
  - **Playwright browser automation**
  - **DuckDuckGo search**

Together, they form a **local, private AI automation stack** that mimics Copilot-like tool orchestration — all without relying on cloud APIs.

---

## 🧰 Project Structure
mcp-server/
├── activate_env.sh # Activates the Python virtual environment
├── setup.sh # Sets up and configures Ollama + MCPHost
├── restart_mcp.sh # Restart script for MCPHost
├── local.json # MCP server configuration file
├── ollama-mcp/ # Filesystem MCP workspace
├── logs/ # Ollama and MCPHost log files
├── Car_Database.db # SQLite demo database
├── github.json # GitHub MCP configuration (optional)
├── playwright.json # Playwright MCP configuration (optional)
└── mcphost.log # MCPHost output log


---

## ⚙️ Setup Instructions

### 1️⃣ Clone and enter the project
```bash
git clone https://github.com/alagammai/ollama-mcp-host-lab.git
cd mcp-server

## ⚙️ Run Order (Important)

### 1️⃣ Activate environment
```bash
bash activate_env.sh

2️⃣ Run setup
bash setup.sh

This installs dependencies, starts the Ollama server, installs MCPHost, and sets up aliases like mcpstart and mcpquiet.

3️⃣ Start MCPHost
mcpstart

🧪 Example Prompts

Once MCPHost is running, try:
“List files in my connected filesystem.”
“Show tables in my SQLite database.”
“Search GitHub repositories for Model Context Protocol.”
“Run a Playwright test for example.com.”



