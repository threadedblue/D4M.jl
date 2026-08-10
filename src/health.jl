# Health check function for D4M diagnostics

"""
    health()

Perform a health check on the D4M module and return status.

Returns:
- "Ok" followed by Julia and D4M versions if all checks pass
- "!Ok" followed by an error message if any check fails

Checks performed:
- Julia version availability
- D4M version availability
- Basic Assoc creation and manipulation

# Examples
```julia
julia> health()
"Ok - Julia v1.10.0, D4M v0.6.10"

julia> health()
"!Ok - Failed to create Assoc: ..."
```
"""
function health()
    try
        juliaVer = string(VERSION)
        d4mVer = pkgVersion()

        # Basic functionality check: create a simple Assoc
        testAA = Assoc(["r1"], ["c1"], [1.0])

        # Verify the Assoc was created correctly
        if nnz(testAA) != 1
            return "!Ok - Assoc creation failed: nnz check"
        end

        return "Ok - Julia v$juliaVer, D4M v$d4mVer"
    catch e
        errorMsg = string(e)
        return "!Ok - $errorMsg"
    end
end

"""
    pkgVersion()

Get the version of the D4M package.

Returns:
- A string with the semantic version number (e.g., "0.6.10")
- "unknown" if the version cannot be determined
"""
function pkgVersion()
    try
        # Try Julia's built-in pkgversion (Julia 1.9+)
        if hasmethod(Base.pkgversion, Tuple{Module})
            ver = Base.pkgversion(D4M)
            if ver !== nothing
                return string(ver)
            end
        end

        # Fallback: try reading from Project.toml in package directory
        projFile = joinpath(dirname(dirname(@__DIR__)), "Project.toml")
        if isfile(projFile)
            content = read(projFile, String)
            # Extract version line: version = "X.Y.Z"
            versionMatch = match(r"version\s*=\s*\"([^\"]+)\"", content)
            if versionMatch !== nothing
                return versionMatch.captures[1]
            end
        end
        return "unknown"
    catch
        return "unknown"
    end
end
