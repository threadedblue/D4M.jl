using Base64, HTTP, JSON

mutable struct JIRA
    url::String
    un::String
    pw::String
end

function cred(jira::JIRA)::String
    return "Basic " * base64encode(jira.un * ":" * jira.pw)
end

function auth(jira::JIRA)::Dict
    return Dict("Authorization" => cred(jira))
end

function getIssues(jira::JIRA, query::String)
    qry::Dict = Dict("jql" => query)
    resp = HTTP.get(jira.url; headers = auth(jira), query = qry)
    println(typeof(resp))
    body::String = String(resp.body)
    json::Dict = JSON.parse(body)
    return json
end
