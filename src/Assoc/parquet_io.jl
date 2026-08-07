using Parquet2
using Arrow
using Tables
using SparseArrays: findnz

"""
    saveParquet(filename, A; compress=:zstd) -> filename

Write Assoc `A` to an Apache Parquet file at `filename`.

The table is built as a Tables.jl NamedTuple (the same columnar layout
used by `saveAA`) and written via `Parquet2.writefile`.

**Wide form** (string-valued Assoc): column `chunkId` holds D4M row keys;
one column per D4M column key; absent cells stored as `missing`. Compatible
with DoubleNaught's Python `AABinaryNormalizer` pipeline.

**Triplet form** (numeric Assoc): columns `_row`, `_col`, `_val` store the
sparse COO representation. The leading underscore distinguishes triplet files
from wide files at load time.

# Arguments
- `filename`: output path; parent directories are created if absent.
- `compress`: Parquet codec — `:zstd` (default), `:snappy`, `:gzip`, or
  `nothing` / `:uncompressed`.
"""
function saveParquet(filename::String, A::Assoc; compress::Union{Symbol,Nothing}=:zstd)
    isempty(A) && error("saveParquet: cannot serialize an empty Assoc")
    dir = dirname(filename)
    isempty(dir) || mkpath(dir)
    codec = isnothing(compress) ? :uncompressed : compress
    if isa(A.val[1], AbstractString)
        _saveParquetWide(filename, A, codec)
    else
        _saveParquetTriplet(filename, A, codec)
    end
    return filename
end

function _saveParquetWide(filename::String, A::Assoc, codec::Symbol)
    nR      = length(A.row)
    nC      = length(A.col)
    colvecs = [Vector{Union{Missing,String}}(missing, nR) for _ in 1:nC]
    I, J, V = findnz(A.A)
    for k in eachindex(I)
        v = Int(V[k])
        v > 0 && (colvecs[J[k]][I[k]] = A.val[v])
    end
    names = tuple(:chunkId, Symbol.(A.col)...)
    vals  = tuple(A.row, colvecs...)
    Parquet2.writefile(filename, NamedTuple{names}(vals); compression_codec=codec)
end

function _saveParquetTriplet(filename::String, A::Assoc, codec::Symbol)
    rs, cs, vs = find(A)
    Parquet2.writefile(filename,
        (rowKey=string.(rs), colKey=string.(cs), val=Float64.(vs));
        compression_codec=codec)
end

"""
    loadParquet(filename) -> Assoc

Load an Assoc from a Parquet file written by `saveParquet` or by
DoubleNaught's Python `AABinaryNormalizer`.

Reads via `Parquet2.Dataset` (Tables.jl interface). Wide-form files
reconstruct a string Assoc; triplet-form files (`rowKey`, `colKey`, `val`
columns, matching the Python `aa_serializer` schema) reconstruct a numeric
Assoc. Arrow list columns are skipped.
"""
function loadParquet(filename::String)
    ds       = Parquet2.Dataset(filename)
    colnames = Symbol.(collect(Tables.columnnames(ds)))
    if colnames == [:rowKey, :colKey, :val] || colnames == [:rowKey, :colKey, :val, :metadata]
        return _loadParquetTriplet(ds)
    end
    return _loadParquetWide(ds, colnames)
end

function _loadParquetWide(ds, colnames)
    isempty(colnames) && return emptyAssoc()
    rowKeys = collect(Tables.getcolumn(ds, first(colnames)))
    rs = String[]; cs = String[]; vs = String[]
    for cn in colnames[2:end]
        cnStr   = string(cn)
        colData = collect(Tables.getcolumn(ds, cn))
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

function _loadParquetTriplet(ds)
    rs = collect(Tables.getcolumn(ds, :rowKey))
    cs = collect(Tables.getcolumn(ds, :colKey))
    vs = collect(Tables.getcolumn(ds, :val))
    return Assoc(rs, cs, Float64.(vs))
end
