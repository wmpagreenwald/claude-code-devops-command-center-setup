# Claude Code and Codex environment setup

This repository contains scripts and templates for setting up a shared working
directory, task-tracking files, instruction files, and three skills:

- `jira` — Jira Server REST API workflows
- `confluence` — Confluence REST API workflows
- `session-start` — session startup and briefing workflow

The scripts configure files on the local machine. They do not install Claude
Code, Codex, Git, external plugins, or repositories, and they do not contain
credentials.

## Choose your client

Use `setup.sh` for Claude Code or `setup-codex.sh` for Codex. The scripts use
the same source templates but install client-specific instruction filenames and
skill locations.

| Client | Global instructions | User skills | Project/repository instructions |
|---|---|---|---|
| Claude Code | `~/.claude/` settings and the configured Git root | `~/.claude/skills/` | `CLAUDE.md` |
| Codex | `~/.codex/AGENTS.md` | `~/.agents/skills/` | `AGENTS.md` |

Codex reads global and project instructions according to its instruction-file
discovery rules. In particular, an `AGENTS.md` at the root of the repository
you are working in is the reliable location for repository-specific guidance.
See the [official Codex AGENTS.md documentation](https://learn.chatgpt.com/docs/agent-configuration/agents-md).

## Prerequisites

Before using the installed setup:

1. Install and authenticate the client you intend to use: Claude Code or Codex.
2. Install Git if you need to clone repositories.
3. Use a shell with Bash. Both scripts are Bash scripts.
4. Obtain the Jira and Confluence base URLs and credentials if you need those
   skills. Do not put credentials in this repository.

## Get the setup files

Clone this repository:

```bash
git clone https://github.com/wmpagreenwald/claude-code-devops-command-center-setup.git
cd claude-code-devops-command-center-setup
```

Run the commands below from this repository directory. If you downloaded an
archive instead, change to the directory containing the selected setup script.

## Claude Code setup

Run:

```bash
bash setup.sh
```

The default installation creates or preserves:

- `~/.claude/skills/jira/SKILL.md`
- `~/.claude/skills/confluence/SKILL.md`
- `~/.claude/skills/session-start/SKILL.md`
- `~/git/CLAUDE.md`
- `~/git/todo.txt`, `todo_deferred.txt`, and `todo_delegated.txt`
- `~/git/project-a/CLAUDE.md` and `~/git/project-b/CLAUDE.md`
- the current `~/git/week-of-MMDDYYYY/` folder
- `~/.claude/settings.json`, copied from the placeholder template only when
  that file does not already exist

The script skips existing destination files and does not merge them. If
`~/.claude/settings.json` already exists, merge the needed values from
`reference/settings.template.json` manually.

### Claude Code follow-up steps

1. Edit `~/.claude/settings.json`. Remove settings you do not use and replace
   the placeholders. The Jira and Confluence skills require:

   ```text
   JIRA_URL
   JIRA_USERNAME
   JIRA_PASSWORD
   CONFLUENCE_URL
   CONFLUENCE_USERNAME
   CONFLUENCE_PASSWORD
   ```

2. Rename `~/git/project-a` and `~/git/project-b`, or provide real names during
   installation:

   ```bash
   PROJECTS="alpha beta" GIT_ROOT="$HOME/work" bash setup.sh
   ```

   Update the directory tree in the installed root instruction file
   (`$GIT_ROOT/CLAUDE.md`, default `~/git/CLAUDE.md`) after changing the names.
   The script creates the requested folders but does not rewrite that tree.

3. Clone your actual repositories into their project folders. This package does
   not clone repositories for you.

4. For each repository, create a repository-level instruction file from
   `reference/example-repo-CLAUDE.md`:

   ```bash
   cp reference/example-repo-CLAUDE.md "$HOME/git/alpha/example-repo/CLAUDE.md"
   ```

   Replace the example path and fill in the template, or remove it if the
   repository does not need repository-specific instructions.

5. If you use Slack, install the Claude plugin separately from Claude Code:

   ```text
   /plugin marketplace add anthropics/claude-plugins-official
   /plugin install slack
   ```

6. Start Claude Code in a repository, run `/skills`, and confirm `jira`,
   `confluence`, and `session-start` are listed. Then run `/session-start`.

## Codex setup

Run:

```bash
bash setup-codex.sh
```

The default installation creates or preserves:

- `~/.codex/AGENTS.md`
- `~/.agents/skills/jira/SKILL.md`
- `~/.agents/skills/confluence/SKILL.md`
- `~/.agents/skills/session-start/SKILL.md`
- `~/git/AGENTS.md`
- `~/git/todo.txt`, `todo_deferred.txt`, and `todo_delegated.txt`
- `~/git/project-a/AGENTS.md` and `~/git/project-b/AGENTS.md`
- the current `~/git/week-of-MMDDYYYY/` folder

The script converts the Claude-oriented source templates to Codex-oriented
`AGENTS.md` files when it installs them. It does not copy
`reference/settings.template.json`, install plugins, or configure credentials.
Codex detects skill changes automatically; if a change does not appear, start a
new Codex session. See the [official Codex skills documentation](https://learn.chatgpt.com/docs/build-skills).

### Codex location overrides

The defaults are:

```text
CODEX_HOME=~/.codex
CODEX_SKILLS_ROOT=~/.agents/skills
GIT_ROOT=~/git
PROJECTS="project-a project-b"
```

Override them when running the script:

```bash
CODEX_HOME="$HOME/.codex" \
CODEX_SKILLS_ROOT="$HOME/.agents/skills" \
GIT_ROOT="$HOME/work" \
PROJECTS="alpha beta" \
bash setup-codex.sh
```

`PROJECTS` is a space-separated list of folder names. The Codex installer
rejects names containing `/` and the exact names `.` and `..`. Keep
`CODEX_SKILLS_ROOT` at its default unless your Codex configuration is set to
load a different skills directory.

### Codex credentials for Jira and Confluence

Before using those skills, make these variables available in the environment
used to run Codex's shell commands:

```bash
export JIRA_URL="https://your-jira-host"
export JIRA_USERNAME="your-username"
export JIRA_PASSWORD="your-password"
export CONFLUENCE_URL="https://your-confluence-host"
export CONFLUENCE_USERNAME="your-username"
export CONFLUENCE_PASSWORD="your-password"
```

Use your organization's approved secret-management method for storing the
values. Do not commit them to this repository or place real values in a tracked
file.

### Codex follow-up steps

1. Rename the generated project folders and update the installed root instruction
   file (`$GIT_ROOT/AGENTS.md`, default `~/git/AGENTS.md`) so its directory tree
   matches the folders you use. The installer creates folders; it does not
   rewrite the template's example names.
2. Clone your repositories into those project folders.
3. For each repository, create an `AGENTS.md` at that repository's own root.
   The repository template is Claude-named, so convert its filename references
   while copying it:

   ```bash
   sed 's/CLAUDE\.md/AGENTS.md/g' \
     reference/example-repo-CLAUDE.md \
     > "$HOME/work/alpha/example-repo/AGENTS.md"
   ```

   Replace the example path and fill in the template, or remove it if the
   repository does not need repository-specific instructions.
4. Start a new Codex CLI or IDE session in one of the repositories and run
   `/skills`. Confirm `jira`, `confluence`, and `session-start` are listed, then
   run `/session-start`.
5. If you need Slack, use Codex CLI's `/plugins` browser to inspect and install
   the plugin if it is available to your account. Plugin installation is
   separate from this script.

## Templates and directory structure

The repository contains the following source files:

```
claude-code-devops-command-center-setup/
├── README.md
├── setup.sh
├── setup-codex.sh
├── skills/
│   ├── jira/SKILL.md
│   ├── confluence/SKILL.md
│   └── session-start/SKILL.md
├── git-structure/
│   ├── CLAUDE.md
│   ├── todo.txt
│   ├── todo_deferred.txt
│   ├── todo_delegated.txt
│   ├── WEEKLY-FOLDERS.txt
│   ├── project-a/.gitkeep
│   └── project-b/.gitkeep
└── reference/
    ├── example-project-CLAUDE.md
    ├── example-repo-CLAUDE.md
    ├── settings.template.json
    └── done-file-format.txt
```

The project and repository instruction files are templates. Fill them in with
verified project information or delete them. Do not leave placeholder content
in active project or repository instruction files.

The package contains no real task history, done files, weekly-folder history,
repositories, credentials, or external plugins. The installers create the
current weekly folder and template task files as part of setup.

## Important caveats

- The Confluence examples use `confluence.example.com` and placeholder space
  keys. They document URL parsing only; the runtime base URL comes from
  `$CONFLUENCE_URL`.
- The Jira and Confluence skills use Basic Auth with the six environment
  variables listed above. The repository does not validate those credentials.
- The Claude installer uses `~/.claude/settings.json`; the Codex installer uses
  `~/.codex/AGENTS.md` by default and does not use that settings template.
- Both installers skip existing files rather than merging or overwriting them.
- Codex's user skills are installed under `~/.agents/skills/`, while
  repository-specific skills, when used, belong under `.agents/skills/` in the
  repository hierarchy described by the official Codex documentation.
