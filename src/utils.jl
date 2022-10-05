module Utils

using Dates: DateTime, DateFormat
using HTTP
using Base
using JSON
using ..Bangumis: config

export date_parse, missing_eq, http_get

struct HTTPGetRequests
    id::Integer
    url::AbstractString
end

const DATE_FORMAT = DateFormat.([
    "d.m.y",
    "y-m-dTH:M:Ss",
    "y-m-dTH:M:S"
])

"""
    date_parse(s)
Parse given object to datetime, return `DateTime(1970)` if parse failed.

# Arguments
- `s::Any`: Parse will only work when `s` is `AbstractString`, otherwise `DateTime(1970)` will be returned.

# Examples
```jldoctest
julia> date_parse(nothing)
1970-01-01T00:00:00
julia> date_parse("1980-1-2")
1980-01-02T00:00:00
```
"""
function date_parse(s)::DateTime
    @warn "解析非字符对象: $s::$(typeof(s))"
    return DateTime(1970)
end

function date_parse(s::AbstractString)::DateTime
    @debug "(日期解析) 输入: $s"
    d = tryparse(DateTime, s)
    if (d isa DateTime)
        return d
    end
    for df in DATE_FORMAT
        d = tryparse(DateTime, s, df)
        if (d isa DateTime)
            return d
        end
    end
    @error "无法解析日期: $s"
    return DateTime(1970)
end

function missing_eq(a, b)::Bool
    if (ismissing(a) && ismissing(b))
        return true
    elseif (ismissing(a) || ismissing(b))
        return false
    else
        return a == b
    end
end

function http_get(url::AbstractString)::HTTP.Messages.Response
    @debug "Send HTTP GET request to $url"
    HTTP.get(url, headers=Dict("User-Agent" => config["http"]["user_agent"]),
        connect_timeout=config["http"]["connect_timeout"], readtimeout=config["http"]["read_timeout"],
        retry=false, redirect_limit=config["http"]["max_redirects"], status_exception=false)
end

function Base.parse(res::HTTP.Messages.Response)
    if (res.status == 200)
        return JSON.parse(String(res.body))
    else
        return Dict()
    end
end

end
