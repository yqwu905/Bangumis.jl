module Bangumis

using TOML: parsefile
using Dates: DateTime

export config, Subject, Episode

struct Subject
    id::Integer
    url::AbstractString
    type::Int
    name::AbstractString
    name_cn::AbstractString
    summary::AbstractString
    air_date::DateTime
    air_weekday::Integer
    images::NamedTuple{
        (:large, :common, :medium, :small, :grid),
        Tuple{
            AbstractString,
            AbstractString,
            AbstractString,
            AbstractString,
            AbstractString,
        },
    }
end

struct Episode
    id::Integer
    type::Integer
    name::AbstractString
    name_cn::AbstractString
    sort::Integer
    ep::Integer
    air_date::DateTime
    comment::Integer
    duration::AbstractString
    desc::AbstractString
    disc::Integer
    subject_id::Integer
end

function f((k, v))
    if (v isa Dict)
        return k => Dict(Iterators.map(f, v))
    elseif (v isa Integer)
        return k => convert(Int, v)
    else
        return k => v
    end
end

const DEFAULT_CONFIG_FILE =
    joinpath(dirname(dirname(pathof(@__MODULE__))), "data", "config.toml")
const config = Dict(Iterators.map(f, parsefile(DEFAULT_CONFIG_FILE)))

include("utils.jl")
using .Utils
export http_get
include("database.jl")
include("schedule.jl")
include("test.jl")
using .Schedule
include("sources.jl")
include("BT/bittorrent.jl")

end
