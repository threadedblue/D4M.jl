# Add required jars to the classpath and initialize the JVM

function dbinit()
    JavaCall.addClassPath(Pkg.dir("D4M")*"/libext/*")
    JavaCall.addClassPath(Pkg.dir("D4M")*"/lib/graphulo-3.0.0.jar")
    JavaCall.init()
end