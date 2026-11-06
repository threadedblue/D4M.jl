---
intent: Implement
mode: Attended            # Attended or Unattended
---

## Subject
To harmonize D4M.jl with D4M.py.

## Current state
Three implementations of D4M exist
1. matlab
2. Julia, land
3. Python

The matlab implementation is of no consequence.
The Julia and Python implementations are operational. However, they are in variance with one another. i.e. They use different names for the same thing and the same name for different things.

## Deliverable
A refactored D4M.jl that has been harmonized with D4M.py.  

## Constraints
D4M.py is not to be changed.
D4M.jl has in it certain enhancements that do not occur in D4M.py.  Leave them, do not update D4M.py.

## Verification
When the D4M.jl names are harmonized with D4M.py according to the file /Users/gcr/populi.Wk/D4M.jl/doc/d4m-name-map.md
