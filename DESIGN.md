# D4M.jl Design & Architecture

## Overview

D4M.jl is the Julia implementation of the Dynamic Distributed Dimensional Data Model (D4M). It provides Associative Array abstractions for working with sparse, high-dimensional data using a row-column-value triplet representation.

## Core Principles

### Associative Array (AA) Representation

An Associative Array is represented as a triplet: `(r, c, v)` where:
- **r** (rows): distinct row keys
- **c** (columns): distinct column keys  
- **v** (values): numeric or string values

### Naming Conventions

All Julia code follows **strict camelCase** for:
- Variable names: `inputArray`, `delimiterVal`, `outputAssoc`
- Function arguments: `splitSep`, `findParams`
- Internal computation variables: `rowKeys`, `colKeys`, `valMatrix`

## Macro Utilities

### `@lift` Macro

**Purpose:** Syntactic sugar for lifting continuous values into structural column keys.

**Signature:**
```julia
@lift(inputArray)
@lift(inputArray, delimiterVal)
```

**Behavior:**
- Takes an Associative Array and promotes its values to column keys using a delimiter.
- Internally calls `val2col(inputArray, delimiterVal)` with all arguments passed through.
- Default delimiter: `"|"` (matches D4M.py convention).

**Example:**
```julia
AA = Assoc(["r1", "r2"], ["c1", "c2"], [1.0, 2.0])
liftedAA = @lift(AA)  # Equivalent to val2col(AA)
liftedAA2 = @lift(AA, ",")  # Equivalent to val2col(AA, ",")
```

**Macro Hygiene:** Uses `esc()` to ensure caller-scope variables are evaluated correctly without hygiene pollution.

### `@drop` Macro

**Purpose:** Syntactic sugar for reverting column-encoded values back into continuous matrix values.

**Signature:**
```julia
@drop(inputArray)
@drop(inputArray, delimiterVal)
```

**Behavior:**
- Takes an Associative Array with column-encoded values and separates them into distinct columns.
- Internally calls `col2type(inputArray, delimiterVal)` with all arguments passed through.
- Default delimiter: `"|"` (matches D4M.py convention).

**Example:**
```julia
AA = Assoc(["r1", "r2"], ["c1|v1", "c2|v2"], 1)
droppedAA = @drop(AA)  # Equivalent to col2type(AA)
droppedAA2 = @drop(AA, ",")  # Equivalent to col2type(AA, ",")
```

**Macro Hygiene:** Uses `esc()` to ensure caller-scope variables are evaluated correctly without hygiene pollution.

## Backward Compatibility

- `val2col()` and `col2type()` remain as the primary, underlying implementation functions.
- The `@lift` and `@drop` macros are thin wrappers providing syntactic convenience.
- All existing code using direct function calls continues to work unchanged.
- New code should prefer `@lift` and `@drop` for readability and symmetry.

## Architecture Notes

### Separation of Concerns

- **Core Functions**: `val2col()` and `col2type()` in `parsinghelpers.jl` handle actual transformation logic.
- **Macros**: `@lift` and `@drop` in `macro_utilities.jl` provide high-level syntactic interface.
- **Testing**: Comprehensive unit tests verify macro output matches direct function calls.

### Future Extensibility

The macro pattern allows for future optimizations (e.g., compile-time analysis, delayed evaluation) without changing the public interface or breaking existing code.
