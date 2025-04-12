module D4M.HTTP.Http.Server

using HTTP

export start_server

"""
    start_server()

Starts an HTTP server on localhost:8888.
Handles GET and POST requests.
"""
function start_server()
    HTTP.serve(router, "127.0.0.1", 8888)
end

"""
    router(request::HTTP.Request)

Routes incoming HTTP requests to the correct handler.
"""
function router(request::HTTP.Request)
    method = request.method

    if method == "GET"
        return handle_get(request)
    elseif method == "POST"
        return handle_post(request)
    else
        return HTTP.Response(405, "Method Not Allowed")
    end
end

"""
    handle_get(request::HTTP.Request)

Stub to handle HTTP GET requests.
"""
function handle_get(request::HTTP.Request)
    # TODO: Fill in your GET handling logic here
    return HTTP.Response(200, "GET received")
end

"""
    handle_post(request::HTTP.Request)

Stub to handle HTTP POST requests.
"""
function handle_post(request::HTTP.Request)
    # TODO: Fill in your POST handling logic here
    return HTTP.Response(200, "POST received")
end

end # module
