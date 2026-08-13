# CLAUDE.md

Template for a REPO-level CLAUDE.md. Lives at the repo root.

Purpose: detail that only matters once this codebase is open. Anything true of the
whole project belongs one level up; anything true of how you work belongs at the
git root. These files legitimately range from ~10 lines (a repo whose only
non-obvious property is its promotion flow) to several hundred (a service with a
build-and-sync pipeline that spans repos). Length should track how much the repo
hides, not a template.

Delete every section that does not earn its place.

## Repository Overview

What this repo produces and where the output goes. The critical thing to capture
is any CROSS-REPO effect — "CI builds an image, pushes it to the registry, then
syncs deployment manifests into <other-repo>, which deploys it" — because that is
what makes a change here land somewhere else, and it is invisible from the source.

If the repo is a component of a larger stack, say which repo is the deployment
target. If it is the deployment target, say which components push into it.

## Project Configuration

Concrete values worth not re-deriving:
- Language and runtime version
- Where the version number lives (e.g. a `VERSION` file) and the current value
- Published artifact name: image path, package name, or chart name
- Deploy target: namespace, environment, or plan
- IaC tool and provider version constraints, if applicable
- Where reusable modules or shared actions are sourced from

## Directory Structure

An annotated tree of the paths that matter, with a one-line note per entry.
Include counts where they set expectations ("28 workflows", "25 modules"). Skip
directories a reader can guess. The goal is knowing which file to open, not a
complete inventory.

## Branch and SDLC Process

Often the only section a repo needs. Record the mechanics, not the intent:
- Which branch is the source of truth, and which branches must never be committed
  to directly
- How promotion happens: automatic on passing CI, or manual dispatch, and from
  which branch
- Merge constraints (e.g. `--ff-only`) and what to do when one fails — investigate
  the divergence rather than forcing through
- Whether cherry-picking between branches is allowed

## Build / Test / Run

The exact commands, including any prerequisite that is not obvious: an env file
that must be populated, a login step, a tool version that must match CI. If a
test suite needs live infrastructure, say so — that is the kind of thing that
otherwise gets discovered the slow way.

## Gotchas

Behavior that has bitten someone before and is not visible in the code. State
what was observed, not what was assumed. Examples of the shape:
- A refactor that requires a state-migration command before apply, or the tool
  will recreate the resource
- A config key that looks live but is consumed by nothing
- A template whose conditional is inverted relative to how it reads
- A hardcoded value that a downstream consumer references directly, so changing
  it changes behavior with no visible diff at the call site
