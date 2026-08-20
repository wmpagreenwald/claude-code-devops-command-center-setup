---
name: session-start
description: Start a work session. Pulls latest changes from all repos, reads instruction files, reads todo/done files, creates today's done file, and surfaces newly unblocked deferred items. Follows the conventions in the root instruction file. Accepts an optional project name to scope the session to a single project subdirectory.
argument-hint: [project-name]
---

Run the session startup sequence.

## Scope

If a project name was passed as an argument, scope the session to that project: resolve it to a single project subdirectory one level below the root by matching the directory name. If no directory matches, stop and ask. Read only that project's instruction file, repositories, and reference files; skip other project subdirectories. Read root-level files, including the root instruction file, task files, weekly session folders, done file, and root reference files, in full.

With no argument, process all projects as described below.

## Structure convention

The root working directory (where the root CLAUDE.md lives) contains:
- Personal task tracking files (todo.txt, todo_deferred.txt, todo_delegated.txt, etc.)
- Weekly session folders (week-of-* or similar) for done files and notes
- Project subdirectories (e.g. project-a/, project-b/) which may have their own CLAUDE.md
- Repo directories nested inside project subdirectories (e.g. project-a/some-repo/)

## Steps

1. **Read root CLAUDE.md** — find the root by looking for CLAUDE.md in or above the current working directory. Read it to understand folder structure, repo layout, todo file names, done file naming conventions, and any session startup instructions.

2. **Read project-level CLAUDE.md files** — check each project subdirectory (one level below root) for a CLAUDE.md and read any that exist.

3. **Pull latest changes** — find all git repositories (directories with a `.git` folder, up to 3 levels deep from root; if scoped to a project, search only within that project's directory). Run `git pull --rebase` on all of them in a single shell command (e.g. a for loop or find -exec) so only one approval is needed. Note repos with new commits and summarize what changed.

4. **Read repo CLAUDE.md files** — for each repo that has a CLAUDE.md, read it.

5. **Read task tracking files** — read all todo/task files at the root (as named in the root CLAUDE.md).

6. **Read recent session notes** — find the weekly/session folders at the root. Read all files from the two most recent folders entirely.

6a. **Read persistent reference files** — read any long-lived reference files that carry session-critical context, such as deployment guides, runbooks, or architecture docs. Some live at the root alongside `todo.txt` and the root instruction file; read those in full. If a project's instruction file points to a guide or runbook hosted in an external system rather than a local file, read it there via the appropriate skill. Do not rely on any local file marked as deprecated.

7. **Create today's done file** — following the naming convention in the root CLAUDE.md, check if a done file for today already exists in the current period folder. If not, create it. If the current period folder doesn't exist yet, create it first.

8. **Check deferred items** — review deferred items and identify any whose stated blocker appears resolved based on recent done files or current todo state. Flag these explicitly.

9. **Present briefing**:
   - Repos with new commits and what changed
   - Prioritized open todos
   - Delegated items status
   - Any deferred items now unblocked
   - Confirm done file location
   - When scoped to a project, state the scope up front and filter the briefing to items relating to that project
