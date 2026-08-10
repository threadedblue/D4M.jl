# Selector types for D4M getindex dispatch.
# Each struct converts to Vector{Int64} via a _resolve() method (see getindex.jl).
# To add a new selector: define the struct here, add _resolve at the bottom.

# ── Between ──────────────────────────────────────────────────────────────────────

struct Between
    lo::String
    hi::String
end

# "lo".."hi" — inclusive range over sorted keys, O(log n) via binary search
..(lo::AbstractString, hi::AbstractString) = Between(string(lo), string(hi))

function BetweenHelper(keys::AbstractVector, b::Between)
    lo = searchsortedfirst(keys, b.lo)
    hi = searchsortedlast(keys, b.hi)
    return lo <= hi ? collect(Int64, lo:hi) : Int64[]
end

_resolve(keys::AbstractVector, b::Between) = BetweenHelper(keys, b)

# ── EndsWith ─────────────────────────────────────────────────────────────────────

struct EndsWith
    suffix::String
end

# O(n) — no ordering shortcut for suffix matching
function EndsWithHelper(keys::AbstractVector, e::EndsWith)
    return findall(k -> endswith(k, e.suffix), keys)
end

_resolve(keys::AbstractVector, e::EndsWith) = EndsWithHelper(keys, e)

# ── Contains ─────────────────────────────────────────────────────────────────────

struct Contains
    substr::String
end

# O(n) — linear scan
function ContainsHelper(keys::AbstractVector, c::Contains)
    return findall(k -> occursin(c.substr, k), keys)
end

_resolve(keys::AbstractVector, c::Contains) = ContainsHelper(keys, c)

# ── BetweenEndsWith ──────────────────────────────────────────────────────────────

struct BetweenEndsWith
    lo::String
    hi::String
end

# ew"00001"..ew"00005" — rows whose key ends with a suffix in [lo, hi].
# lo and hi must be the same character length (typical for zero-padded integers).
..(lo::EndsWith, hi::EndsWith) = BetweenEndsWith(lo.suffix, hi.suffix)

function _resolve(keys::AbstractVector, b::BetweenEndsWith)
    n = length(b.lo)
    return findall(k -> length(k) >= n && b.lo <= last(k, n) <= b.hi, keys)
end

# ── String literal macros ─────────────────────────────────────────────────────────
# sw"prefix"  → StartsWith("prefix")   (StartsWith defined in getindex.jl)
# ew"suffix"  → EndsWith("suffix")
# has"substr" → Contains("substr")
# ew"lo"..ew"hi" → BetweenEndsWith("lo", "hi")

macro sw_str(s::String);  :(StartsWith($s));  end
macro ew_str(s::String);  :(EndsWith($s));    end
macro has_str(s::String); :(Contains($s));    end

# ── Transformation macros ────────────────────────────────────────────────────────
# @lift and @drop provide syntactic sugar for value-to-column lifting and dropping.

"""
    @lift(inputArray)
    @lift(inputArray, delimiterVal)

Macro that lifts continuous values into structural column keys.

Internally calls `val2col(inputArray, delimiterVal)` with all arguments passed through.
Default delimiter is "|" (matching D4M.py convention).

# Examples
```julia
AA = Assoc(["r1", "r2"], ["c1", "c2"], [1.0, 2.0])
liftedAA = @lift(AA)  # Equivalent to val2col(AA)
liftedAA2 = @lift(AA, ",")  # Equivalent to val2col(AA, ",")
```
"""
macro lift(args...)
    if length(args) == 1
        # @lift(inputArray) -> val2col(inputArray)
        return :(val2col($(esc(args[1]))))
    elseif length(args) == 2
        # @lift(inputArray, delimiterVal) -> val2col(inputArray, delimiterVal)
        return :(val2col($(esc(args[1])), $(esc(args[2]))))
    else
        error("@lift expects 1 or 2 arguments, got $(length(args))")
    end
end

"""
    @drop(inputArray)
    @drop(inputArray, delimiterVal)

Macro that reverts column-encoded values back into continuous matrix values.

Internally calls `col2type(inputArray, delimiterVal)` with all arguments passed through.
Default delimiter is "|" (matching D4M.py convention).

# Examples
```julia
AA = Assoc(["r1", "r2"], ["c1|v1", "c2|v2"], 1)
droppedAA = @drop(AA)  # Equivalent to col2type(AA)
droppedAA2 = @drop(AA, ",")  # Equivalent to col2type(AA, ",")
```
"""
macro drop(args...)
    if length(args) == 1
        # @drop(inputArray) -> col2type(inputArray)
        return :(col2type($(esc(args[1]))))
    elseif length(args) == 2
        # @drop(inputArray, delimiterVal) -> col2type(inputArray, delimiterVal)
        return :(col2type($(esc(args[1])), $(esc(args[2]))))
    else
        error("@drop expects 1 or 2 arguments, got $(length(args))")
    end
end
