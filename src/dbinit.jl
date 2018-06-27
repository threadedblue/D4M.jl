# Adds required jars to the classpath and initializes the JVM
using JavaCall

function dbinit()
    if ~JavaCall.isloaded()
        JavaCall.addClassPath(Pkg.dir("D4M")*"/libext/*")
        JavaCall.addClassPath(Pkg.dir("D4M")*"/lib/graphulo-3.0.0.jar")
        JavaCall.init()
    else
        println("JVM already initialized")

        # Check if correct packages are on classpath
        System = @jimport java.lang.System
        cpath = jcall(System,"getProperty",JString,(JString,),"java.class.path")

        if ~contains(cpath,"graphulo")
            println("Required libraries for database operations missing from Java classpath. Restart Julia and intialize jvm using dbinit().")
        end
    end
end