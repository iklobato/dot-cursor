#!/usr/bin/env bash
set -euo pipefail

AGENT="cursor-agent"
SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
REPO_DIR="$(dirname "$SCRIPT_DIR")"
OUTPUT_DIR="${1:-/tmp/dot-cursor-validate}"
AGENT_OPTS="--print --trust --approve-mcps"
USE_CACHED="${CURSOR_VALIDATE_USE_CACHED:-0}"

run_test() {
  local name="$1"
  local prompt="$2"
  local out="$OUTPUT_DIR/${name}.txt"
  if [ "$USE_CACHED" = "1" ] && [ -f "$REPO_DIR/tests/cached/$name.txt" ]; then
    cp "$REPO_DIR/tests/cached/$name.txt" "$out"
    echo "[$name] Using cached output"
  else
    echo "[$name] Running... (timeout 180s)"
    if ! timeout 180 $AGENT $AGENT_OPTS --workspace "$REPO_DIR" "$prompt" > "$out" 2>&1; then
      echo "[$name] FAIL: cursor-agent exited non-zero or timed out"
      return 1
    fi
  fi
  echo "[$name] Got $(wc -c < "$out") bytes"
  return 0
}

mkdir -p "$OUTPUT_DIR"
echo "Output dir: $OUTPUT_DIR"
echo

# Collect outputs
run_test "minimal" "What is 2+2? Reply with only the number." || exit 1
run_test "antihallucination" "I need Terraform for a database. I have not decided provider, region, or state backend. What should I provide first?" || exit 1
run_test "controlflow" "Write a Python function parity(n) that returns 'even' or 'odd'. Use only early returns. No else, no elif. Max 6 lines." || exit 1

# Build evaluation prompt for cursor-agent to self-assess
RULES=$(cat "$REPO_DIR/agent.json")
MINIMAL=$(cat "$OUTPUT_DIR/minimal.txt")
ANTI=$(cat "$OUTPUT_DIR/antihallucination.txt")
CONTROL=$(cat "$OUTPUT_DIR/controlflow.txt")

EVAL_PROMPT="You are evaluating whether cursor-agent output followed these rules:

---
$RULES
---

Three outputs were captured:

1. MINIMAL (prompt: 'What is 2+2? Reply with only the number.'):
---
$MINIMAL
---

2. ANTIHALLUCINATION (prompt: 'I need Terraform for a database. I have not decided provider, region, or state backend. What should I provide first?'):
---
$ANTI
---

3. CONTROLFLOW (prompt: 'Write a Python function parity(n)... Use only early returns. No else, no elif.'):
---
$CONTROL
---

Did each output follow the rules? Consider: no emojis, minimal/required-only output, asks instead of inventing for ambiguous requests, no else/elif in code.

Reply with exactly this format, nothing else:
minimal: PASS or FAIL
antihallucination: PASS or FAIL
controlflow: PASS or FAIL
OVERALL: PASS or FAIL"

echo
if [ -n "${CURSOR_VERDICT:-}" ]; then
  echo "Using injected verdict (CURSOR_VERDICT)"
  VERDICT="$CURSOR_VERDICT"
else
  echo "Asking cursor-agent to evaluate (timeout 180s)..."
  VERDICT=$(timeout 180 $AGENT $AGENT_OPTS --workspace "$REPO_DIR" "$EVAL_PROMPT" 2>&1) || true
fi

if [ -n "$VERDICT" ]; then
  echo "$VERDICT"
  echo
fi

if echo "$VERDICT" | grep -qi 'OVERALL: PASS'; then
  echo "OK: cursor-agent evaluated config as working"
  exit 0
fi

if [ -z "$VERDICT" ]; then
  echo "FAIL: cursor-agent evaluation timed out or failed (no verdict)"
else
  echo "FAIL: cursor-agent evaluated config as not working"
fi
exit 1
