module D4M.HTTP.HttpClient

using HTTP
using JSON3 
export get_request, post_request

"""
    get_request(url::String)

Performs an HTTP GET request to the specified URL.
Returns the response body as a string.
"""
function get_request(url::String)
    response = HTTP.get(url)
    return String(response.body)
end

"""
    post_request(url::String, data::Dict)

Performs an HTTP POST request to the specified URL.
`data` will be sent as JSON.
Returns the response body as a string.
"""
function post_request(url::String, data::Dict)
    body = JSON3.write(data)  # serialize Dict to JSON
    headers = ["Content-Type" => "application/json"]
    response = HTTP.post(url, headers, body)
    return String(response.body)
end

end # module
