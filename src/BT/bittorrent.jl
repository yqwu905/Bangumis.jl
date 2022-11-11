# This module implement very little functionality of BitTorrent protocol. Only
# the decode of BEncode, and query seeder from tracker are implement.
module BitTorrent

export get_seeder_status

using SHA

include("bencode.jl")
include("tracker.jl")

function get_info_hash(torrent_file::AbstractString)::Vector{UInt8}
    info = BEncode.bdecode(read(torrent_file))["info"]
    if (haskey(info, "pieces"))
        pieces = info["pieces"]
        info["pieces"] = Vector{UInt8}(pieces)
    end
    return sha1(BEncode.bencode(info))
end

function get_seeder_status(torrent_file::AbstractString)::Dict{String, Integer}
    bdata = BEncode.bdecode(read(torrent_file))
    tracker = bdata["announce"]
    info_hash = String(get_info_hash(torrent_file))
    resp = Tracker.query_tracker(tracker, info_hash, 0)
    info = BEncode.bdecode(resp.body)
    return Dict(
        "complete" => get(info, "complete", 0),
        "downloaded" => get(info, "downloaded", 0),
        "incomplete" => get(info, "incomplete", 0),
    )
end

end
