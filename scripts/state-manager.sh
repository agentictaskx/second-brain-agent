#!/usr/bin/env bash
# state-manager.sh — Manages session state for the second-brain-agent
# Usage: ./scripts/state-manager.sh [init|save|load|status]

set -euo pipefail

VAULT_ROOT="$(cd "$(dirname "$0")/.." && pwd)"
STATE_FILE="$VAULT_ROOT/raw/sessions/state.json"
SESSION_DIR="$VAULT_ROOT/raw/sessions"
TODAY=$(date +%Y-%m-%d)
SESSION_FILE="$SESSION_DIR/${TODAY}-session.md"

case "${1:-status}" in
  init)
    mkdir -p "$SESSION_DIR"
    if [ ! -f "$STATE_FILE" ]; then
      cat > "$STATE_FILE" << 'INIT'
{
  "last_session": null,
  "identity_cached": false,
  "total_operations": 0,
  "last_operation": null
}
INIT
      echo "State initialized at $STATE_FILE"
    else
      echo "State already exists at $STATE_FILE"
    fi

    if [ ! -f "$SESSION_FILE" ]; then
      cat > "$SESSION_FILE" << LEDGER
# Session Ledger: $TODAY

| Time | Operation | Tools Used | Raw Sources | Wiki Pages | Outcome |
|------|-----------|------------|-------------|------------|---------|
LEDGER
      echo "Session ledger created at $SESSION_FILE"
    else
      echo "Session ledger already exists for today"
    fi
    ;;

  save)
    # Save state — called by Actor after operations
    # Expects JSON on stdin or as $2
    local_state="${2:-$(cat)}"
    echo "$local_state" > "$STATE_FILE"
    echo "State saved"
    ;;

  load)
    if [ -f "$STATE_FILE" ]; then
      cat "$STATE_FILE"
    else
      echo '{"last_session": null, "identity_cached": false, "total_operations": 0, "last_operation": null}'
    fi
    ;;

  status)
    echo "=== Second Brain State ==="
    echo "Vault: $VAULT_ROOT"
    echo "Today: $TODAY"
    if [ -f "$STATE_FILE" ]; then
      echo "State: $(cat "$STATE_FILE")"
    else
      echo "State: not initialized (run: ./scripts/state-manager.sh init)"
    fi
    if [ -f "$SESSION_FILE" ]; then
      lines=$(wc -l < "$SESSION_FILE")
      echo "Session ledger: $SESSION_FILE ($lines lines)"
    else
      echo "Session ledger: not started"
    fi
    echo ""
    echo "Wiki pages: $(find "$VAULT_ROOT/wiki" -name '*.md' 2>/dev/null | wc -l)"
    echo "Raw sources: $(find "$VAULT_ROOT/raw" -name '*.md' -not -path '*/sessions/*' 2>/dev/null | wc -l)"
    echo "Playbooks: $(find "$VAULT_ROOT/playbooks" -name '*.md' 2>/dev/null | wc -l)"
    ;;

  *)
    echo "Usage: $0 [init|save|load|status]"
    exit 1
    ;;
esac
