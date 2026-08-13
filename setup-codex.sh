#!/usr/bin/env bash
# Installs the Claude Code working environment for Codex users.
# Idempotent: never overwrites an existing file. Prints what it skipped.
#
# Override defaults with:
#   CODEX_HOME=~/.codex CODEX_SKILLS_ROOT=~/.agents/skills GIT_ROOT=~/work ./setup-codex.sh
#   PROJECTS="alpha beta gamma" ./setup-codex.sh
set -euo pipefail

PKG="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CODEX_HOME_DIR="${CODEX_HOME:-$HOME/.codex}"
CODEX_SKILLS_ROOT="${CODEX_SKILLS_ROOT:-$HOME/.agents/skills}"
GIT_ROOT_DIR="${GIT_ROOT:-$HOME/git}"
PROJECTS_TEXT="${PROJECTS:-project-a project-b}"
tmp_file=""

usage() {
  cat <<'EOF'
Usage: ./setup-codex.sh

Environment overrides:
  CODEX_HOME          Codex home directory (default: ~/.codex)
  CODEX_SKILLS_ROOT   User skill directory (default: ~/.agents/skills)
  GIT_ROOT            Git folder structure root (default: ~/git)
  PROJECTS            Space-separated project folder names
EOF
}

while [ "$#" -gt 0 ]; do
  case "$1" in
    --help|-h)
      usage
      exit 0
      ;;
    *)
      echo "ERROR: unknown option: $1" >&2
      usage >&2
      exit 2
      ;;
  esac
done

cleanup() {
  if [ -n "$tmp_file" ] && [ -e "$tmp_file" ]; then
    rm -f "$tmp_file"
  fi
}
trap cleanup EXIT

path_exists() {
  [ -e "$1" ] || [ -L "$1" ]
}

copy_if_absent() {
  local src=$1 dst=$2
  if path_exists "$dst"; then
    echo "  SKIP (exists): $dst"
  else
    mkdir -p "$(dirname "$dst")"
    cp "$src" "$dst"
    echo "  ok:            $dst"
  fi
}

copy_codex_file_if_absent() {
  local src=$1 dst=$2
  if path_exists "$dst"; then
    echo "  SKIP (exists): $dst"
  else
    mkdir -p "$(dirname "$dst")"
    tmp_file="$(mktemp "$(dirname "$dst")/.codex-setup.XXXXXX")"
    sed \
      -e 's/Claude Code Preferences/Codex Preferences/g' \
      -e 's/CLAUDE\.md/AGENTS.md/g' \
      -e 's/Install the Slack plugin (not included - it is a marketplace package):/Install the Slack plugin through Codex if needed:/g' \
      -e 's#       /plugin marketplace add anthropics/claude-plugins-official#       Start Codex and run /plugins.#g' \
      -e 's#       /plugin install slack#       Choose the Slack plugin and install it there.#g' \
      "$src" > "$tmp_file"
    mv "$tmp_file" "$dst"
    tmp_file=""
    echo "  ok:            $dst"
  fi
}

if [ -n "$PROJECTS_TEXT" ]; then
  read -r -a project_names <<< "$PROJECTS_TEXT"
else
  project_names=()
fi
for project_name in "${project_names[@]}"; do
  case "$project_name" in
    ""|.|..|*/*)
      echo "ERROR: PROJECTS contains an invalid project folder name: '$project_name'" >&2
      exit 2
      ;;
  esac
done

echo "Package:        $PKG"
echo "Codex home:     $CODEX_HOME_DIR"
echo "User skills:    $CODEX_SKILLS_ROOT"
echo "Git root:       $GIT_ROOT_DIR"
echo "Projects:       $PROJECTS_TEXT"
echo

echo "1. Skills -> $CODEX_SKILLS_ROOT/"
for skill in jira confluence session-start; do
  if [ "$skill" = session-start ]; then
    copy_codex_file_if_absent "$PKG/skills/$skill/SKILL.md" "$CODEX_SKILLS_ROOT/$skill/SKILL.md"
  else
    copy_if_absent "$PKG/skills/$skill/SKILL.md" "$CODEX_SKILLS_ROOT/$skill/SKILL.md"
  fi
done
echo

echo "2. Global Codex instructions -> $CODEX_HOME_DIR/"
copy_codex_file_if_absent "$PKG/git-structure/CLAUDE.md" "$CODEX_HOME_DIR/AGENTS.md"
echo

echo "3. Git root instructions and task files -> $GIT_ROOT_DIR/"
mkdir -p "$GIT_ROOT_DIR"
copy_codex_file_if_absent "$PKG/git-structure/CLAUDE.md" "$GIT_ROOT_DIR/AGENTS.md"
for file in todo.txt todo_deferred.txt todo_delegated.txt; do
  copy_if_absent "$PKG/git-structure/$file" "$GIT_ROOT_DIR/$file"
done
echo

echo "4. Project folders"
for project_name in "${project_names[@]}"; do
  if [ -d "$GIT_ROOT_DIR/$project_name" ]; then
    echo "  SKIP (exists): $GIT_ROOT_DIR/$project_name"
  else
    mkdir -p "$GIT_ROOT_DIR/$project_name"
    echo "  ok:            $GIT_ROOT_DIR/$project_name"
  fi
done
echo

echo "5. Project-level AGENTS.md template -> each project folder"
for project_name in "${project_names[@]}"; do
  copy_codex_file_if_absent \
    "$PKG/reference/example-project-CLAUDE.md" \
    "$GIT_ROOT_DIR/$project_name/AGENTS.md"
done
echo "  NOTE: these are TEMPLATES with placeholder text. Fill them in or delete"
echo "        them - a project AGENTS.md full of placeholders is worse than none."
echo

echo "6. Current week folder"
monday=""
if command -v python3 >/dev/null 2>&1; then
  monday=$(python3 -c 'import datetime as d; t=d.date.today(); print((t - d.timedelta(days=t.weekday())).strftime("%m%d%Y"))')
elif date -v-1d >/dev/null 2>&1; then
  monday=$(date -v-$(( $(date +%u) - 1 ))d +%m%d%Y)
else
  monday=$(date -d "-$(( $(date +%u) - 1 )) day" +%m%d%Y)
fi
case "$monday" in
  [0-9][0-9][0-9][0-9][0-9][0-9][0-9][0-9]) ;;
  *)
    echo "  ERROR: could not compute the week-of date (got '$monday')." >&2
    echo "  Create the folder by hand: $GIT_ROOT_DIR/week-of-MMDDYYYY (Monday-dated)." >&2
    monday=""
    ;;
esac
if [ -n "$monday" ]; then
  week_dir="$GIT_ROOT_DIR/week-of-$monday"
  if [ -d "$week_dir" ]; then
    echo "  SKIP (exists): $week_dir"
  else
    mkdir -p "$week_dir"
    echo "  ok:            $week_dir"
  fi
fi
echo

cat <<'EOF'
Done. Remaining manual steps:

  1. Review ~/.codex/AGENTS.md and adjust the working agreements for your setup.

  2. Rename the project folders to your real project prefixes, then update the
     directory tree in <git-root>/AGENTS.md to match.

  3. Run /skills in Codex and confirm jira, confluence, and session-start are
     listed. Restart Codex if a newly installed skill does not appear.
EOF
