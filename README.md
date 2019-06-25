# Julia-D4M

D4M.jl is a library for Julia that allows unstructured data to be represented as triples in sparse matrices (Associative Arrays) and can be manipulated using standard linear algebraic operations.
Using D4M it is possible to construct advanced analytics with just a few lines of code.
D4M was initially developed in MATLAB by Dr Jeremy Kepner and his team at Lincoln Laboratory. The goal is to implement D4M in a native Julia method.

The D4M Project Page: <https://d4m.mit.edu/>

Current Status: Many of the functionalities of core D4M have been implemented. Database connection capabilites to come.

## Documentation

- See below for installation brief use instructions.
- For examples of more extensive use, see the examples.
- The Matlab D4M distribution contains an eight lecture course in its documentation (<https://github.com/Accla/d4m> in d4m/docs). Many of the examples from this course have been translated to Julia and the concepts are relevant to both the Matlab and Julia versions, and so this course could serve as an introduction to D4M.jl as well.
- When citing D4M in publications, please use:
  - [Kepner et al, ICASSP 2012] Dynamic Distributed Dimensional Data Model (D4M) Database and Computation System, J. Kepner, W. Arcand, W. Bergeron, N. Bliss, R. Bond, C. Byun, G. Condon, K. Gregson, M. Hubbell, J. Kurz, A. McCabe, P. Michaleas, A. Prout, A. Reuther, A. Rosa & C. Yee, ICASSP (International Conference on Acoustics, Speech, and Signal Processing), Special session on Signal and Information Processing for "Big Data" (organizers: Bliss & Wolfe), March 25-30, 2012, Kyoto, Japan

## Requirements

D4M.jl is written and tested to work with Julia v1.0. The final Julia 0.6 compatible version of D4M is available in "Releases" or on the julia-0.6 branch. It requires the `JLD` package for saving and loading associative arrays and the `PyPlot` package for plotting spy plots. For database connectivity, it relies on `JavaCall`. See the Database Use section of this document for more information.

## Installation

You can use the `Pkg.add()` command to install D4M.jl in your package directory:

```julia
pkg> add https://github.com/Accla/D4M.jl.git
```

Once you have added the D4M.jl package, you can update it using the `Pkg.update()` command:

```julia
pkg> up D4M
```

You can test that your installation is working by running:

```julia
pkg> test D4M
```

For an offline installation  of D4M.jl, you can use the `Pkg.add()` command and specify the path to the D4M.jl directory:

```julia
pkg> add /path/to/D4M.jl
```

For for the most up to date information on installing and working with Julia packages, view the Julia documentation on the subject: <https://docs.julialang.org/en/stable/stdlib/Pkg/.>

## Basic Use

Start by loading the D4M.jl package:

```julia
using D4M
```

Associaitve Arrays can be constructed from strings, arrays of strings, scalars, and arrays of numbers as row keys, column keys, and values:

```julia
row = "a,a,a,a,a,a,a,aa,aaa,b,bb,bbb,a,aa,aaa,b,bb,bbb,"
column = "a,aa,aaa,b,bb,bbb,a,a,a,a,a,a,a,aa,aaa,b,bb,bbb,"
values = "a-a,a-aa,a-aaa,a-b,a-bb,a-bbb,a-a,aa-a,aaa-a,b-a,bb-a,bbb-a,a-a,aa-aa,aaa-aaa,b-b,bb-bb,bbb-bbb,"

A = Assoc(row,column,values)
```

You can get particular rows and columns of associative arrays by using row and column indexing, as well as get the entries where the values satisfy some condition.

```julia
Ar = A["a,b,",:];
Ac = A[:,"a,b,"];
Av = A > "b,"
```

Associative arrays support a variety of mathematical operations, including addition, subtraction, matrix multiplication, elementwise multiplication/division, summing across rows/columns, and more.

```julia
A + B
A - B
A * B
A .* B
A ./ B
sum(A,1)
sum(A,2)
```

For more examples of how you can use D4M.jl, check out the examples in the examples directory, including some examples with real datasets. A Jupyter notebook is provided with these examples as well.

***NOTE***
Various parts of this implementation has been completed and compared with the original matlab in performance.  In the matrix performance example folder (testing performance in matrix like operations such as add and multiply), this implementation has achieved on par if not significant speed up (10x).

## Database Use

Use of the database connection capabilites requires Graphulo. Graphulo is available on this page: <https://github.com/Accla/graphulo>.

We have provided the jars that were used to test this version of D4M.jl, 

If you would like to include a different version of Graphulo, you can provide your own jars. To do this, build Graphulo according to the instructions on that page. There should be two jars and one zip file in the "target" directory after you build Graphulo. The jar ending with "alldeps.jar" is the server side jar meant to go with your Accumulo instance. The other jar should be placed in the "lib" folder in the D4M.jl package directory and the zip file should be unzipped into the D4M.jl package directory. The resulting "libext" directory contains dependency jars.

D4M.jl does rely on the JavaCall package to call the Graphulo functions that enable database communication. In order for JavaCall to initialize the JVM, the JAVA_HOME environment variable must be set and the above jars must be on the classpath before initializing the JVM. Note that as of now, the JavaCall package does not allow anything to be added to the classpath after intializing the JVM, and the JVM cannot be "unitialized" except by exiting Julia.

For convenience we add these jars to your classpath and initialize the JVM on your first dbsetup() call. If you need other jars on your classpath, add these before calling this function. If you are running on a Mac, you may get a Segmentation fault when running this function, you can most likely ignore it. See <http://juliainterop.github.io/JavaCall.jl/faq.html> for more information.