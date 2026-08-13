# <Project Name>

Template for a PROJECT-level CLAUDE.md. Lives at `~/git/<project>/CLAUDE.md`.

Purpose: what this project is and how it operates. This is also the layer where
root-level defaults get overridden — if the root CLAUDE.md describes a promotion
flow or branching model this project does not follow, say so here explicitly.
Delete sections that do not apply; do not leave placeholder text in place.

## What <Project> Is

Two to four sentences: what the system does, who consumes it, where it is hosted,
and the high-level architecture. Name the source org so repo lookups are
unambiguous. Note anything in flight (a platform migration, a rewrite) along with
the date the note was written, so a later reader can judge whether it is stale.

## Repos

| Repo | Purpose |
|---|---|
| `<repo>` | One line. Include what it deploys or publishes, and to where. |
| `<repo>` | Flag repos with no active CI, or ones that are legacy/read-only. |

List relevant repos that are NOT cloned locally too — shared workflow repos and
service repos are often needed for context even when not checked out.

## Infrastructure / Stack

- IaC tool and where the definitions live. State this explicitly: assuming the
  wrong tool wastes a lot of time.
- Environment names exactly as they appear in deploy workflows, including region
  suffixes.
- Key resource naming patterns, and any environment that deviates.

## SDLC

If a project has more than one deployment model, describe each separately and say
plainly not to conflate them.

### <Model A — e.g. service repos>
How a build is triggered, what the release tag convention is, and which shared
workflows are called.

### <Model B — e.g. the infra repo>
Same, plus any promotion gate enforced inside the workflow rather than by
convention. Record how the gate actually behaves, verified against a real run.

### Branching
- Mainline name (it may differ per repo) and whether direct commits are allowed.
- Feature branch naming, usually the ticket ID.
- How changes land: PR, who reviews, which merge methods are enabled.

## Git

- Call out where this project departs from the root CLAUDE.md conventions.
- Repeat the non-negotiables: check the branch before committing, no pushing
  without explicit approval.

## People

Name, role, and what they own or are the contact for. Cite where the list came
from and how current it is — team pages go stale and a wrong owner sends work to
the wrong person.

## Task Tracking

- Ticket ID format (e.g. `PROJ-1234`) and whether todo entries should carry one.
- If tracking is two-sided (local files plus a tracker), say what must stay
  current in the tracker: assignee, status, closing comment.
- Record the REAL status mapping for this board, including any place the generic
  Jira skill's assumptions are wrong for it. Re-confirm available transitions
  against the live issue rather than reusing a recorded transition id.

## Pull Requests

Where to announce a PR, the message format the team uses, and who to add as
reviewer. Include link-markup conventions if the team has them.

## Documentation

Which space/system holds this project's docs, the landing page, and how much to
trust it. If pages predate a major platform change, say so.
