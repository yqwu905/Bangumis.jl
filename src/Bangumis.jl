module Bangumis

using TOML: parsefile

export config

struct Subject
    id::Integer
    url::AbstractString
    type::Int
    name::AbstractString
    name_cn::AbstractString
    summary::AbstractString
    air_date::DateTime
    air_weekday::Integer
    images::NamedTuple{(:large, :common, :medium, :small, :grid), Tuple{AbstractString, AbstractString, AbstractString, AbstractString, AbstractString}}
end

struct Episode
    id::Integer
    type::Integer
    name::AbstractString
    name_cn::AbstractString
    sort::Integer
    ep::Integer
    air_date::DateTime
    comment::AbstractString
    duration::AbstractString
    desc::AbstractString
    disc::AbstractString
end

const DEFAULT_CONFIG_FILE = joinpath(
    dirname(dirname(pathof(@__MODULE__))), "data", "config.toml")
config = parsefile(DEFAULT_CONFIG_FILE)

include("utils.jl")
include("database.jl")

end
