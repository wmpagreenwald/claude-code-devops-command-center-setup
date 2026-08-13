#!/usr/bin/env bash
# Installs the Claude Code working environment on a new machine.
# Idempotent: never overwrites an existing file. Prints what it skipped.
#
# Project folders are generic placeholders (project-a, project-b). Override with:
#   PROJECTS="foo bar baz" ./setup.sh
set -euo pipefail

PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
GIT_ROOT="${GIT_ROOT:-$HOME/git}"
CLAUDE_DIR="$HOME/.claude"
PROJECTS="${PROJECTS:-project-a project-b}"

echo "Package:      $PKG"
echo "Git root:     $GIT_ROOT"
echo "Claude dir:   $CLAUDE_DIR"
echo "Projects:     $PROJECTS"
echo

copy_if_absent() {
  local src=$1 dst=$2
  if [ -e "$dst" ]; then
    echo "  SKIP (exists): $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  ok:            $dst"
  fi
}

echo "1. Skills -> $CLAUDE_DIR/skills/"
for s in jira confluence session-start; do
  copy_if_absent "$PKG/skills/$s/SKILL.md" "$CLAUDE_DIR/skills/$s/SKILL.md"
done
echo

echo "2. Root instruction file and task files -> $GIT_ROOT/"
mkdir -p "$GIT_ROOT"
for f in CLAUDE.md todo.txt todo_deferred.txt todo_delegated.txt; do
  copy_if_absent "$PKG/git-structure/$f" "$GIT_ROOT/$f"
done
echo

echo "3. Project folders"
for d in $PROJECTS; do
  if [ -d "$GIT_ROOT/$d" ]; then
    echo "  SKIP (exists): $GIT_ROOT/$d"
  else
    mkdir -p "$GIT_ROOT/$d"
    echo "  ok:            $GIT_ROOT/$d"
  fi
done
echo

echo "4. Project-level CLAUDE.md template -> each project folder"
for d in $PROJECTS; do
  copy_if_absent "$PKG/reference/example-project-CLAUDE.md" "$GIT_ROOT/$d/CLAUDE.md"
done
echo "  NOTE: these are TEMPLATES with placeholder text. Fill them in or delete"
echo "        them - a project CLAUDE.md full of placeholders is worse than none."
echo

echo "5. Current week folder"
# Monday of the current week, as MMDDYYYY. python3 first because it behaves
# identically everywhere; BSD (macOS) and GNU date differ in flag syntax.
monday=""
if command -v python3 >/dev/null 2>&1; then
  monday=$(python3 -c 'import datetime as d; t=d.date.today(); print((t - d.timedelta(days=t.weekday())).strftime("%m%d%Y"))')
elif date -v-1d >/dev/null 2>&1; then
  monday=$(date -v-$(( $(date +%u) - 1 ))d +%m%d%Y)          # BSD / macOS
else
  monday=$(date -d "-$(( $(date +%u) - 1 )) day" +%m%d%Y)    # GNU
fi
case "$monday" in
  [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) ;;
  *) echo "  ERROR: could not compute the week-of date (got '$monday')." >&2
     echo "  Create the folder by hand: $GIT_ROOT/week-of-MMDDYYYY (Monday-dated)." >&2
     monday="" ;;
esac
if [ -n "$monday" ]; then
  WEEK="$GIT_ROOT/week-of-$monday"
  if [ -d "$WEEK" ]; then
    echo "  SKIP (exists): $WEEK"
  else
    mkdir -p "$WEEK"
    echo "  ok:            $WEEK"
  fi
fi
echo

echo "6. Settings"
if [ -e "$CLAUDE_DIR/settings.json" ]; then
  echo "  SKIP (exists): $CLAUDE_DIR/settings.json"
  echo "  Merge the env block from reference/settings.template.json by hand."
else
  mkdir -p "$CLAUDE_DIR"
  cp "$PKG/reference/settings.template.json" "$CLAUDE_DIR/settings.json"
  echo "  ok:            $CLAUDE_DIR/settings.json  (TEMPLATE - edit it)"
fi
echo

cat <<'EOF'
Done. Remaining manual steps:

  1. Edit ~/.claude/settings.json and replace every REPLACE_ME value.
     The six JIRA_/CONFLUENCE_ vars are required by the jira and
     confluence skills; no credentials ship in this package.

  2. Rename the project folders to your real project prefixes, then update the
     directory tree in <git-root>/CLAUDE.md to match.

  3. Install the Slack plugin (not included - it is a marketplace package):
       /plugin marketplace add anthropics/claude-plugins-official
       /plugin install slack

  4. Clone repos into the project folders.

  5. Verify: run /skills and confirm jira, confluence and
     session-start are listed, then run /session-start.
EOF
