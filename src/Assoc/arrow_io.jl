using Arrow
using Tables
using SparseArrays: findnz

"""
    saveAA(filename, A; compress=:zstd) -> filename

Write Assoc `A` to an Apache Arrow IPC (Feather v2) file at `filename`.

**Wide form** (string-valued Assoc, `isa(A.val[1], AbstractString)`):
Column `chunkId` holds D4M row keys; one Arrow field per D4M column key;
absent cells stored as `missing`. Files are directly compatible with
DoubleNaught's Python `AABinaryNormalizer` pipeline.

**Triplet form** (numeric Assoc, `A.val == [1.0]`):
Columns `_row`, `_col`, `_val` store the sparse COO representation.
The leading underscore distinguishes triplet files from wide files at load
time.

# Arguments
- `filename`: output path; parent directories are created if absent.
- `A`: the Assoc to serialize.
- `compress`: Arrow codec — `:zstd` (default), `:lz4`, or `nothing`.

# Examples
```julia
A = Assoc("r1,r2,", "text,author,", "hello,world,gilbert,gilbert,")
saveAA("/tmp/corpus.arrow", A)
B = loadAA("/tmp/corpus.arrow")
```
"""
function saveAA(filename::String, A::Assoc; compress::Union{Symbol,Nothing}=:zstd)
    isempty(A) && error("saveAA: cannot serialize an empty Assoc")
    dir = dirname(filename)
    isempty(dir) || mkpath(dir)
    if isa(A.val[1], AbstractString)
        _saveWide(filename, A, compress)
    else
        _saveTriplet(filename, A, compress)
    end
    return filename
end

function _saveWide(filename::String, A::Assoc, compress)
    nR   = length(A.row)
    nC   = length(A.col)
    # Allocate one missing-filled buffer per D4M column key.
    colvecs = [Vector{Union{Missing,String}}(missing, nR) for _ in 1:nC]
    # Fill from the CSC sparse matrix; V[k] is an index into A.val.
    I, J, V = findnz(A.A)
    for k in eachindex(I)
        v = Int(V[k])
        v > 0 && (colvecs[J[k]][I[k]] = A.val[v])
    end
    names = tuple(:chunkId, Symbol.(A.col)...)
    vals  = tuple(A.row, colvecs...)
    Arrow.write(filename, NamedTuple{names}(vals); compress=compress)
end

function _saveTriplet(filename::String, A::Assoc, compress)
    rs, cs, vs = find(A)
    Arrow.write(filename,
        (_row=string.(rs), _col=string.(cs), _val=Float64.(vs));
        compress=compress)
end

"""
    loadAA(filename) -> Assoc

Load an Assoc from an Arrow IPC file written by `saveAA` or by
DoubleNaught's Python `AABinaryNormalizer`.

- **Wide form** (any column layout): first column is the row-key source
  (typically `chunkId`); remaining scalar string columns become D4M column
  keys.  Arrow list columns (`scores`, `inputIds`, etc.) are skipped.
- **Triplet form** (columns `_row`, `_col`, `_val`): reconstructs a
  numeric Assoc from COO data written by `saveAA` for numeric Assocs.
"""
function loadAA(filename::String)
    tbl      = Arrow.Table(filename)
    colnames = collect(Tables.columnnames(tbl))
    if colnames == [:_row, :_col, :_val]
        return _loadTriplet(tbl)
    end
    return _loadWide(tbl, colnames)
end

function _loadWide(tbl, colnames)
    isempty(colnames) && return emptyAssoc()
    rowKeys = collect(Tables.getcolumn(tbl, first(colnames)))
    rs = String[]; cs = String[]; vs = String[]
    for cn in colnames[2:end]
        cnStr   = string(cn)
        colData = collect(Tables.getcolumn(tbl, cn))
        for (i, val) in enumerate(colData)
            if !ismissing(val) && isa(val, AbstractString)
                push!(rs, string(rowKeys[i]))
                push!(cs, cnStr)
                push!(vs, string(val))
            end
        end
    end
    isempty(rs) && return emptyAssoc()
    return Assoc(rs, cs, vs)
end

function _loadTriplet(tbl)
    rs = collect(Tables.getcolumn(tbl, :_row))
    cs = collect(Tables.getcolumn(tbl, :_col))
    vs = collect(Tables.getcolumn(tbl, :_val))
    return Assoc(rs, cs, Float64.(vs))
end
