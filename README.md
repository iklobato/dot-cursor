# dot-cursor

Cursor Agent CLI configuration for consistent behavior across systems.

## Contents

- `agent.json` – Default instructions for the cursor-agent CLI
- `cli-config.example.json` – Example `cli-config.json` (no sensitive data)
- `Taskfile.yml` – `task install` to symlink config into `~/.cursor`

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

   This creates `~/.cursor`, symlinks `agent.json`, and copies `cli-config.example.json` if `cli-config.json` does not exist.

3. Authenticate and validate:

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
