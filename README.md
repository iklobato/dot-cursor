# dot-cursor

Cursor Agent CLI configuration for consistent behavior across systems.

## Contents

- `agent.json` – Default instructions for the cursor-agent CLI
- `.cursor-agent.yaml` – YAML config with `agent.default_instructions`
- `cli-config.example.json` – Example `cli-config.json` (no sensitive data)

## Setup on a new system

1. Clone this repo:

   ```bash
   git clone git@github.com:iklobato/dot-cursor.git ~/dot-cursor
   ```

2. Symlink config files into `~/.cursor`:

   ```bash
   mkdir -p ~/.cursor
   ln -sf ~/dot-cursor/agent.json ~/.cursor/agent.json
   ln -sf ~/dot-cursor/.cursor-agent.yaml ~/.cursor/.cursor-agent.yaml
   ```

3. Create `cli-config.json` (login first via `cursor-agent login`):

   ```bash
   cp ~/dot-cursor/cli-config.example.json ~/.cursor/cli-config.json
   ```

   Then run `cursor-agent login` to add auth. The CLI will merge your auth into the file.

4. Validate:

   ```bash
   cursor-agent about
   cursor-agent --print "What is 2+2? Reply with only the number."
   ```

## Update after changing config

```bash
cd ~/dot-cursor
git pull
# Symlinks will reflect changes immediately
```
