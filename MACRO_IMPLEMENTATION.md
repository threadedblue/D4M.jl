# Macro Implementation Summary: `@lift` and `@drop`

## Overview

Two new macros have been introduced to the D4M.jl module to provide syntactic sugar for common Associative Array transformations:
- `@lift`: Lifts continuous values into structural column keys (wraps `val2col`)
- `@drop`: Reverts column-encoded values back into matrix values (wraps `col2type`)

## Implementation Details

### Files Created

1. **DESIGN.md**
   - Documents the architectural design and motivation
   - Includes usage examples for both macros
   - Explains backward compatibility guarantees

### Files Modified

1. **src/Assoc/selectors.jl**
   - Added `@lift` and `@drop` macro definitions to the end of the file
   - Uses proper macro hygiene with `esc()` to prevent variable capture
   - Supports both default separator ("|") and custom delimiter forms
   - Includes complete docstrings with usage examples

2. **src/D4M.jl**
   - Added `@lift, @drop` to the export list

3. **test/runtests.jl**
   - Added comprehensive test suite with 6 new test cases:
     - `@lift – default separator` 
     - `@lift – custom separator`
     - `@drop – default separator`
     - `@drop – custom separator`
     - `@lift and @drop roundtrip`
     - `@lift – result is numeric`

### Call-Sites Refactored

Two existing call-sites have been updated to use the new macros:

1. **ccdWorkspace/ccdPatient.jl (line 12)**
   ```julia
   # Before
   Atxe = val2col(Ttxe, "|")
   
   # After
   Atxe = @lift(Ttxe, "|")
   ```

2. **ccdWorkspace/ccdPractitioner.jl (line 14)**
   ```julia
   # Before
   global Aperf = val2col(Aperf, "|")
   
   # After
   global Aperf = @lift(Aperf, "|")
   ```

## Test Results

All 155 tests pass, including:
- 6 new macro-specific tests
- 149 existing tests (unchanged)

**Test Summary:**
```
Test Summary: | Pass  Total   Time
D4M.jl        |  155    155  10.6s
     Testing D4M tests passed
```

## Macro Signatures

### `@lift` Macro

**Syntax:**
```julia
@lift(inputArray)              # default separator "|"
@lift(inputArray, delimiterVal)
```

**Behavior:**
- Lifts continuous values in an Associative Array into structural column keys
- Internally expands to `val2col(inputArray, delimiterVal)`
- Uses `esc()` for proper hygiene

**Example:**
```julia
AA = Assoc(["r1", "r2"], ["c1", "c2"], [1.0, 2.0])
lifted = @lift(AA)  # Same as val2col(AA)
lifted2 = @lift(AA, ",")  # Same as val2col(AA, ",")
```

### `@drop` Macro

**Syntax:**
```julia
@drop(inputArray)              # default separator "|"
@drop(inputArray, delimiterVal)
```

**Behavior:**
- Reverts column-encoded values back into continuous matrix values
- Internally expands to `col2type(inputArray, delimiterVal)`
- Uses `esc()` for proper hygiene

**Example:**
```julia
AA = Assoc(["r1", "r2"], ["c1|v1", "c2|v2"], 1)
dropped = @drop(AA)  # Same as col2type(AA)
dropped2 = @drop(AA, ",")  # Same as col2type(AA, ",")
```

## Backward Compatibility

- **`val2col()` and `col2type()` remain fully functional** — no changes to the underlying functions
- **Existing code continues to work unchanged** — the macros are optional syntactic sugar
- **New code should prefer `@lift` and `@drop`** for improved readability and semantic clarity

## Code Quality & Standards

### Naming Conventions

All variable names and arguments strictly follow **camelCase**:
- `inputArray`: Input Associative Array parameter
- `delimiterVal`: Custom delimiter value
- `liftedAA`, `droppedAA`: Results of macro expansion

### Macro Hygiene

Both macros use `esc()` to properly escape arguments, ensuring:
- Caller-scope variables are evaluated in the correct context
- No variable capture or hygiene pollution
- Predictable, transparent macro behavior

### Error Handling

Both macros validate argument count and raise informative errors:
```julia
error("@lift expects 1 or 2 arguments, got $(length(args))")
error("@drop expects 1 or 2 arguments, got $(length(args))")
```

## Future Extensions

The macro framework enables future optimizations without changing the public interface:
- Compile-time analysis and optimization
- Delayed evaluation and lazy transformation
- Custom middleware or pre/post-processing hooks
- Type-directed specialization

All extensions can be added to `src/Assoc/selectors.jl` while preserving backward compatibility.

## Testing Strategy

### Unit Tests

Each macro has dedicated test coverage:

1. **Default separator tests**: Verify default "|" behavior
2. **Custom separator tests**: Verify custom delimiter handling
3. **Roundtrip tests**: `@lift` followed by `@drop` returns original data
4. **Output type tests**: Verify `@lift` produces numeric Associative Arrays
5. **Equivalence tests**: Macros produce identical output to direct function calls

### Comparison Approach

Tests use the `sorted_triples()` helper function to compare results in an order-independent manner, ensuring robustness across different internal orderings.

## Usage Recommendations

### When to Use `@lift`

- Converting continuous, unstructured values into categorical structural dimensions
- Preparing data for dimensional analysis or faceted queries
- Improving semantic clarity when transforming data shape

### When to Use `@drop`

- Reconstructing original AA format from column-encoded data
- Reversing dimension lift operations (roundtrip workflows)
- Normalizing data back to flat triplet form

### When to Use Direct Functions

- If you need to pass `val2col` or `col2type` as function references (e.g., to `map()`)
- In performance-critical paths where the direct function is already optimized
- When maintaining legacy code patterns for consistency
