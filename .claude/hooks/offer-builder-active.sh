#!/bin/bash
# offer-builder — v1.1.1
# UserPromptSubmit hook — injects memory context into every session.
# Profile and session log are injected in full. Mechanisms, markets, and offers
# are injected as frontmatter summaries only — the skill Reads the full file on demand.

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
MEMORY_DIR="$PROJECT_DIR/memory"
MEMORY_INDEX="$MEMORY_DIR/MEMORY.md"
PROFILE="$MEMORY_DIR/user-profile.md"
SESSION_LOG="$MEMORY_DIR/session-log.md"
MECH_DIR="$MEMORY_DIR/mechanisms"
MARKETS_DIR="$MEMORY_DIR/markets"
OFFERS_DIR="$MEMORY_DIR/offers"

if [ ! -d "$MEMORY_DIR" ] || [ ! -f "$MEMORY_INDEX" ]; then
  echo "Offer-Builder is active. No memory found in this directory."
  echo "When the user invokes /offer-builder, begin with onboarding (Step 1)."
  exit 0
fi

if grep -q "Status: pending" "$MEMORY_INDEX"; then
  echo "Offer-Builder is active. Memory is initialized but onboarding has not been completed."
  echo "When the user invokes /offer-builder, begin with onboarding (Step 1)."
  exit 0
fi

echo "--- OFFER-BUILDER MEMORY (loaded) ---"
echo "Read all sections before responding."
echo "Do not ask for information already present in memory."
echo "Libraries below show frontmatter only — Read the full file before working a specific mechanism, market, or offer."
echo ""

echo "## Memory Index"
cat "$MEMORY_INDEX"
echo ""

if [ -f "$PROFILE" ]; then
  echo "## Student Profile"
  cat "$PROFILE"
  echo ""
fi

# Print YAML frontmatter only (up to and including the second --- line)
print_frontmatter() {
  awk '{ print } /^---$/ { c++; if (c == 2) exit }' "$1"
}

if [ -d "$MECH_DIR" ]; then
  for f in "$MECH_DIR"/mechanism-*.md; do
    if [ -f "$f" ]; then
      echo "## Mechanism — $(basename "$f" .md)  (summary — full file: memory/mechanisms/$(basename "$f"))"
      print_frontmatter "$f"
      echo ""
    fi
  done
fi

if [ -d "$MARKETS_DIR" ]; then
  for f in "$MARKETS_DIR"/market-*.md; do
    if [ -f "$f" ]; then
      echo "## Market — $(basename "$f" .md)  (summary — full file: memory/markets/$(basename "$f"))"
      print_frontmatter "$f"
      echo ""
    fi
  done
fi

if [ -d "$OFFERS_DIR" ]; then
  for f in "$OFFERS_DIR"/offer-*.md; do
    if [ -f "$f" ]; then
      echo "## Offer — $(basename "$f" .md)  (summary — full file: memory/offers/$(basename "$f"))"
      print_frontmatter "$f"
      echo ""
    fi
  done
fi

if [ -f "$SESSION_LOG" ]; then
  echo "## Session Log"
  cat "$SESSION_LOG"
  echo ""
fi

echo "--- END OFFER-BUILDER MEMORY ---"
