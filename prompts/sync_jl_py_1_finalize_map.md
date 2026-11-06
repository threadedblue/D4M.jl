---
intent: Implement
mode: Attended
---

## Subject
Finalize the D4M.jl to D4M.py name map before any renaming. Step 1 of 2.

## Current state
D4M.jl and D4M.py are both operational but disagree: different names for the same operation, and the same name for different operations. D4M.py is the naming authority.

A draft map is in `doc/d4m-name-map.md` (Python names are the target). It was built from names, signatures and docstrings; nothing has been run. Rows marked VERIFY are unchecked.

Python reference: https://github.com/Accla/D4M.py at commit `e1ded1b`. Clone it into a scratch directory outside D4M.jl.

D4M.jl is on branch `red` with uncommitted changes to `src/Assoc/accessor.jl`, `condense.jl`, `operations.jl`, `Project.toml` and `Manifest.toml`.

## Deliverable
An updated `doc/d4m-name-map.md` in which every VERIFY row is resolved by reading both implementations and, where Julia can run it, by calling the Julia function on a small Assoc and comparing with the Python docstring. Each row ends as one of: rename, same (no change), different meaning (do not rename), or open question. No source files change in this step.

## Constraints
D4M.py is not to be changed. D4M.jl source is not to be changed in this step. Julia-only enhancements are left alone (section D of the map). The `*` versus `@` difference is not resolved by renaming. Do not touch the uncommitted changes.

## Verification
- Every row in sections A and B of the map has a status and a one-line reason.
- A list of the questions left open, for me to decide.
- `git status` in D4M.jl is unchanged from before the step.
