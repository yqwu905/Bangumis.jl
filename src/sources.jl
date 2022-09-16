module Sources

"""
    Bangumis.Sources.Source(name, url, query, download, index)
Represent a source site.

# Arguments
- `name::AbstractString`: the name of the source site.
- `url::AbstractString`: the url of the source site.
- `query::Union{Missing, Function}`: function for query with given keyword,
        missing if source site do not support query.
- `download::Union{Missing, Function}`: function for query with given keyword,
        missing if source site do not support download.
- `index::Union{Missing, Function}`: function for query with given keyword,
        missing if source site do not support index.
"""
struct Source
    name::AbstractString
    url::AbstractString
    query::Union{Missing,Function}
    download::Union{Missing,Function}
    index::Union{Missing,Function}
end

Base.show(io::IO, s::Source) = print(
    io,
    "Source: $(s.name) at $(s.url)
    - Query: $(ismissing(s.query) ? "Not support" : "Support")
    - Download: $(ismissing(s.download) ? "Not support" : "Support")
    - Index: $(ismissing(s.index) ? "Not support" : "Support")"
)

end
