# Claude Code environment package

Transports a Claude Code working setup to another machine: the git folder
structure, the root-level instruction file, project- and repo-level instruction
file templates, and three custom skills.

Project names are generic placeholders throughout. Nothing in this package is
tied to a specific project, org, or person.

## Contents

```
claude-setup/
├── README.md
├── setup.sh                          # installer; idempotent, never overwrites
├── skills/
│   ├── jira/SKILL.md                 # Jira REST API + auth and JSON-parsing workarounds
│   ├── confluence/SKILL.md           # Confluence REST API, same pattern
│   └── session-start/SKILL.md        # daily startup sequence
├── git-structure/                    # installs to ~/git (override with GIT_ROOT)
│   ├── CLAUDE.md                     # ROOT instruction file
│   ├── todo.txt                      # empty, format rules as comments
│   ├── todo_deferred.txt
│   ├── todo_delegated.txt
│   ├── WEEKLY-FOLDERS.txt            # explains week-of-* folders; not copied
│   └── project-a/  project-b/        # placeholder project folders
└── reference/
    ├── example-project-CLAUDE.md     # PROJECT-level template
    ├── example-repo-CLAUDE.md        # REPO-level template
    ├── settings.template.json        # env vars with placeholders, NO credentials
    └── done-file-format.txt          # done-file conventions + skeleton
```

## Install

```bash
unzip claude-setup.zip
cd claude-setup
./setup.sh

# or name your projects up front:
PROJECTS="alpha beta gamma" GIT_ROOT=~/work ./setup.sh
```

`setup.sh` skips anything that already exists, so it is safe to re-run.

## The three instruction-file levels

- **Root** (`git-structure/CLAUDE.md`) — how you work, independent of project:
  folder layout, todo/done/weekly-folder conventions, writing style, git and
  deployment-promotion discipline, verification rules. Installs to the git root.
- **Project** (`reference/example-project-CLAUDE.md`) — what a project is and how
  it operates: architecture, environments, repo inventory, SDLC, people. Also
  where root-level defaults get overridden for that project. Lives at
  `<git-root>/<project>/CLAUDE.md`.
- **Repo** (`reference/example-repo-CLAUDE.md`) — detail that only matters with
  the codebase open: layout, entry points, versions, build/deploy mechanics, and
  cross-repo effects. Lives at the repo root.

Both examples are structural templates with guidance on what belongs in each
section, not filled-in files. A project CLAUDE.md left full of placeholder text
is worse than not having one, so fill them in or delete them.

## What is deliberately NOT included

- **Credentials.** The skills reference `$JIRA_USERNAME`/`$JIRA_PASSWORD` and
  `$CONFLUENCE_USERNAME`/`$CONFLUENCE_PASSWORD` and contain no literal secrets.
  Real values live in `~/.claude/settings.json` on the source machine; move them
  across out of band.
- **The Slack plugin.** Marketplace-installed
  (`slack@claude-plugins-official`), so it is reinstalled rather than copied. On
  the source machine it is the only plugin and supplies every MCP tool in use —
  no MCP servers are configured directly in settings.
- **Real todo/done content and weekly folders.** Task files ship empty with their
  format rules as comments; work history stays on the source machine.
- **Repos.** Clone them into the project folders.

## Caveats

- The two Confluence URLs inside `confluence/SKILL.md` use
  `confluence.example.com` with placeholder space keys. They are input-format
  examples for the skill's URL-parsing rules, and both URL shapes
  (`/display/{space}/{title}` and `/spaces/{space}/pages/{id}/{title}`) must stay
  intact for that section to make sense. The real base URL comes from
  `$CONFLUENCE_URL` at runtime.
- `setup.sh` skips rather than merges. If `~/.claude/settings.json` already
  exists, merge the env block by hand.
- The root `CLAUDE.md` contains a directory tree naming the placeholder project
  folders. Update it after renaming them, or it will describe a layout that does
  not exist.
- `session-start` derives conventions from the root `CLAUDE.md` at runtime, so it
  follows whatever that file says. If you change the todo or done file naming,
  the skill needs no edit.
