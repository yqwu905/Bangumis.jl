module Tracker

using Random: randstring
using HTTP: escapeuri
using ...Bangumis.Utils: http_get

function query_tracker(
    tracker::AbstractString,
    info_hash::AbstractString,
    left::Integer,
    peer_id::Union{Nothing, AbstractString} = nothing,
    port=6881,
    uploaded=0,
    downloaded=0,
    event="empty"
)
    info_hash = escapeuri(info_hash)
    if (isnothing(peer_id))
        peer_id = escapeuri(randstring(20))
    end
    url = "$(tracker)?info_hash=$(info_hash)&peer_id=$(peer_id)&port=$(port)&left=$(left)&uploaded=$(uploaded)&downloaded=$(downloaded)&event=$(event)"
    resp = http_get(url)
    return resp
end

end
