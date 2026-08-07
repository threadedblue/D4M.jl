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
