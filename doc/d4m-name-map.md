# D4M.jl to D4M.py name map (Python names are the target)

Direction: **D4M.py is the naming authority. D4M.jl changes; D4M.py does not.**
Python reference: github.com/Accla/D4M.py at commit `e1ded1b` (`D4M/assoc.py`, `D4M/util.py`).
Status: **FINAL for step 2** (step 1 checked; owner decisions below). Every row below was checked by reading the Julia and Python source and docstrings.
Julia was **not run** (no Julia available to the reviewer), so "same behaviour" means "same by the code and docs".
The earlier Julia-canonical draft is kept as `d4m-name-map.jl-canonical.md`.

Rule for every rename: the old Julia name keeps working (deprecated alias, still exported).

## A. Rename: new Julia name = Python name (12)

| Old Jl | New Jl | Py | Result of check |
|---|---|---|---|
| `getrow` | `get_row` | `Assoc.get_row` | Same idea. Jl may return a `1:n` range for numeric keys, and copies; Py returns the stored array itself. Keep Jl return types. |
| `getcol` | `get_col` | `Assoc.get_col` | As `getrow`. |
| `getval` | `get_val` | `Assoc.get_val` | Same: sorted unique values. |
| `getadj` | `get_adj` | `Assoc.get_adj` | Same; Jl returns a copy, Py the stored matrix. |
| `sqIn` | `sqin` | `Assoc.sqin` | Same (A'A). |
| `sqOut` | `sqout` | `Assoc.sqout` | Same (AA'). |
| `CatKeyMul` | `catkeymul` | `Assoc.catkeymul(other, delimiter=";")` | Same result. Jl hardcodes ";" and has no delimiter argument (see Q3). |
| `CatValMul` | `catvalmul` | `Assoc.catvalmul(other, pair_delimiter=",", delimiter=";")` | Same idea; Jl has no delimiter arguments (see Q3). |
| `col2type` | `col_to_type` | `col_to_type(A, separator="\|", convert=True)` | Same; default separator already "\|". Py has an extra `convert` flag. |
| `ReadCSV` | `readcsv` | `readcsv(filename, labels, triples, ...)` | **Name only.** Signatures differ completely (see Q1). |
| `WriteCSV` | `writecsv` | `writecsv(A, filename, **fmt)` | **Name only.** Signatures differ (see Q1). |
| `printFull` | `printfull` | `Assoc.printfull(cutoff_rows, cutoff_cols)` | Name only; Py has display options. |

## B. Already the same name: checked, no change

| Name | Result |
|---|---|
| `Assoc` | constructor; same role |
| `val2col` | same; default separator "\|" in both. Py adds `int_aware`. |
| `find` | same triple. Py has an optional `ordering`. |
| `logical`, `norow`, `nocol` | same; both return a new Assoc by default |
| `diag`, `condense`, `transpose`, `nnz`, `size` | same idea |
| `sum` | same, but **index base differs**: Jl `sum(A, 1)` sums down columns, which is Py `sum(0)`; Jl `2` is Py `1`. Leave (see Q4). |
| `combine` | same name, different call shape: Jl `combine(A, B, f)`, Py `A.combine(B, f, ...)`. Not a rename. |

## C. Do not rename (different meaning or signature)

| Jl | Py | Why |
|---|---|---|
| `putRow(A, k)` (and `putCol`, `putVal`) | `A.set_row(keys)` (and `set_col`, `set_val`, `set_adj`) | Jl rebuilds every triple under ONE new key. Py replaces the key array in place, needs a compatible shape. `putAdj` vs `set_adj` still unchecked. |
| `right_overwrite(A,B)`, `left_overwrite(A,B)` | `util.last`, `util.first` | Py functions are element functions you pass to `combine`. Jl functions are whole-array operations. |
| `StartsWith`, `Contains` | `util.startswith`, `util.contains` | Jl returns selector objects; Py returns index closures. |
| `CatStr(s1, sep, s2)` | `util.catstr(a, b, separator, int_aware)` | **Argument order differs** (separator is second in Jl, third in Py). A plain rename would silently break calls translated from Py. See Q2. |
| `str2num(A::Assoc, type)` | `util.str_to_num(array)` | Different input: Jl takes an Assoc and a target type, Py takes an array. |
| `A * B` | `A @ B` | Jl `*` is matrix multiply; Py `*` is element-wise. Julia cannot define `@`. Leave `*`. Optionally add Julia-only `matmul(A, B)`. |
| `A .* B` | `A * B`, `multiply` | element-wise; leave |
| (none) | `A & B`, `A \| B` | not in Jl; do not add in this task |

## D. Julia-only: leave unchanged

`EndsWith`, `Between`, `..`, `@sw_str`, `@ew_str`, `@has_str`, `@lift`, `@drop`, `SplitStr`, `NumStr`,
`convertvals`, `saveAA`, `loadAA`, `saveParquet`, `loadParquet`, `toTable`, `toDataFrame`,
`printDataFrame`, `toTriplet`, `printTriple`, `bounded`, `strictbounded`, `adjbfs`, `OutDegree`,
`InDegree`, `health`, `right_overwrite`, `left_overwrite`, `putAdj/putRow/putCol/putVal`, `StartsWith`, `Contains`.

## E. Python-only: no action (D4M.py must not change; do not port)

`dropzeros`, `deepcondense`, `to_dict`, `to_dict2`, `triples`, `spy`, `min`, `max`, `divide`,
comparison operators, `assoc_equal`, `is_empty_assoc`, `read_mat`, `save_mat`, `sorted_union`,
`sorted_intersect`, `num_to_str`, and the `db` module.

## F. Consumers of the Julia names (must keep working)

OntologyAnvil.jl, `d4m_juliacall_bridge` (`bridge.py`, uses `saveParquet`/`loadParquet`/`Assoc`), and the
DoubleNaught backend. Keep old names exported as deprecated aliases; migrate consumers separately.

## Decisions (owner, 2026-11-06)

- **Q1 CSV:** rename `ReadCSV`/`WriteCSV` to `readcsv`/`writecsv`, names only. Keep Julia's arguments.
- **Q2 `catstr`:** add a new `catstr(a, b, separator="|")` in Python's argument order. Keep `CatStr` unchanged. This is an addition, not a rename.
- **Q3 delimiters:** do NOT add `delimiter` arguments to `catkeymul` / `catvalmul`.
- **Q4 `sum`:** keep Julia's `dim` (1, 2). Document the mapping to Python's `axis` (0, 1) in the docstring.
- **Q5 `toTriplet` vs `triples`:** no action.
- **Q6 `putAdj` vs `set_adj`:** no action.

Rows in sections A and C that say "see Qn" are settled by the decisions above.
