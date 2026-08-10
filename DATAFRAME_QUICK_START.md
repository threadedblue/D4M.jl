# DataFrame I/O — Quick Start Guide

## TL;DR

```julia
using D4M

A = Assoc(["r1", "r2"], ["c1", "c2"], ["v1", "v2"])

# Convert to table (no dependencies)
table = toTable(A)

# Convert to DataFrame (requires: using DataFrames)
df = toDataFrame(A)

# Quick inspect
printDataFrame(A)

# Get vectors for processing
rows, cols, vals = toTriplet(A)
```

## The 4 Functions at a Glance

| Function | Returns | Requires | When to Use |
|----------|---------|----------|------------|
| `toTable()` | NamedTuple[] | Nothing | CSV export, Tables.jl |
| `toDataFrame()` | DataFrame | DataFrames.jl | Analysis, manipulation |
| `toTriplet()` | (rows, cols, vals) | Nothing | Custom processing |
| `printDataFrame()` | Prints table | Nothing | Quick inspect |

## Recipes

### Recipe 1: Display in REPL

```julia
using D4M
A = Assoc(["r1", "r2"], ["c1", "c2"], ["v1", "v2"])
printDataFrame(A)
```

### Recipe 2: Export to CSV

```julia
using D4M, CSV
A = Assoc(["r1", "r2"], ["c1", "c2"], ["v1", "v2"])
CSV.write("data.csv", toTable(A))
```

### Recipe 3: Analyze in DataFrames

```julia
using D4M, DataFrames
A = Assoc(["r1", "r2", "r1"], ["c1", "c2", "c2"], ["v1", "v2", "v3"])
df = toDataFrame(A)
unique(df.row)  # Get unique rows
```

### Recipe 4: Custom Column Names

```julia
using D4M, DataFrames
A = Assoc(["r1", "r2"], ["c1", "c2"], ["v1", "v2"])
rows, cols, vals = toTriplet(A)
df = DataFrame(source=rows, feature=cols, measurement=vals)
```

### Recipe 5: Jupyter Display

```julia
using D4M, DataFrames
A = Assoc(["r1", "r2"], ["c1", "c2"], ["v1", "v2"])
toDataFrame(A)  # Automatically displays nicely
```

## Common Tasks

### "I want to see my Assoc as a table"

**Option A (no dependencies):**
```julia
printDataFrame(A)
```

**Option B (prettier, requires DataFrames):**
```julia
using DataFrames
toDataFrame(A)
```

### "I want to save my Assoc to a file"

**CSV:**
```julia
using CSV
CSV.write("output.csv", toTable(A))
```

**JSON:**
```julia
using JSON
JSON.write("output.json", toTable(A))
```

### "I want to work with my Assoc in DataFrames"

```julia
using DataFrames
df = toDataFrame(A)
# Now use all DataFrame operations
```

### "I want to extract the data as arrays"

```julia
rows, cols, vals = toTriplet(A)
# Now you have three separate arrays
```

### "I want to rename the columns"

```julia
using DataFrames
rows, cols, vals = toTriplet(A)
df = DataFrame(
    myrows=rows,
    mycols=cols, 
    myvals=vals
)
```

## Error Messages & Solutions

### Error: "DataFrames.jl is required for toDataFrame()"

**Solution:** Load DataFrames before calling toDataFrame
```julia
using DataFrames  # Add this line
df = toDataFrame(A)
```

### Error: Assoc is too large to display

**Solution:** Use filtering or limit output
```julia
df = toDataFrame(A)
first(df, 10)  # First 10 rows
```

## Performance Tips

- `toTable()` - Fastest, use for export
- `toTriplet()` - Fast, use for processing
- `toDataFrame()` - Slightly slower due to DataFrame creation
- `printDataFrame()` - For inspection only

For very large Assoc (>100k rows), consider streaming to CSV directly instead of converting to DataFrame.

## Integration with Common Libraries

### With CSV.jl
```julia
using CSV
CSV.write("output.csv", toTable(A))
CSV.write("output.csv", toDataFrame(A))
```

### With JSON.jl
```julia
using JSON
JSON.write("output.json", toTable(A))
```

### With DataFrames.jl
```julia
using DataFrames
df = toDataFrame(A)
```

### With Arrow.jl
```julia
using Arrow
Arrow.write("output.arrow", toDataFrame(A))
```

## Cheat Sheet

```julia
using D4M, DataFrames, CSV

A = Assoc(["r1","r2"], ["c1","c2"], ["v1","v2"])

# Display
printDataFrame(A)
toDataFrame(A)

# Export
CSV.write("out.csv", toTable(A))

# Process
df = toDataFrame(A)
rows, cols, vals = toTriplet(A)

# Filter
df_filtered = df[df.row .== "r1", :]

# Unique values
unique(df.row)
unique(df.col)
```

---

For detailed documentation, see: [DATAFRAME_IO.md](DATAFRAME_IO.md)
