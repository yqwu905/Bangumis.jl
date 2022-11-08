module BitTorrent

using SHA

include("bencode.jl")

function get_info_hash(torrent_file::AbstractString)::Vector{UInt8}
    info = BEncode.bdecode(read(torrent_file))["info"]
    if (haskey(info, "pieces"))
        pieces = info["pieces"]
        info["pieces"] = Vector{UInt8}(pieces)
    end
    return BEncode.bencode(info) |> sha1
end

end
