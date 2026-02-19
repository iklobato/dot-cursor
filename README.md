# dot-cursor

Cursor Agent CLI configuration for consistent behavior across systems.

## Contents

- `agent.json` – Default instructions for the cursor-agent CLI
- `cli-config.example.json` – Example `cli-config.json` (permissions, display, model; no sensitive data)
- `mcp.example.json` – MCP servers template (GitHub, sequential-thinking, filesystem; use `${GITHUB_TOKEN}` placeholders)
- `Taskfile.yml` – `task install` to symlink and copy config into `~/.cursor`

## Setup on a new system

1. Clone this repo:

   ```bash
   git clone git@github.com:iklobato/dot-cursor.git ~/dot-cursor
   cd ~/dot-cursor
   ```

2. Run the install task ([Task](https://taskfile.dev/) required):

   ```bash
   task install
   ```

   This creates `~/.cursor`, symlinks `agent.json`, copies `cli-config.example.json` if missing, and copies `mcp.example.json` to `mcp.json` if missing.

3. Configure MCP (if using `mcp.json`): Replace `${GITHUB_TOKEN}` in `~/.cursor/mcp.json` with your token, or set env vars if your MCP runner expands them.

4. Authenticate and validate:

   ```bash
   cursor-agent login
   cursor-agent about
   cursor-agent --print "What is 2+2? Reply with only the number."
   ```

## Update after changing config

```bash
cd ~/dot-cursor
git pull
# Symlinks will reflect changes immediately
```
