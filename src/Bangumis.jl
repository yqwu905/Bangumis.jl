module Bangumis

using TOML: parsefile
using Dates: DateTime
import Logging

Logging.global_logger(Logging.ConsoleLogger(stdout, Logging.Debug))

export config, Subject, Episode
export Job, Result, create_jobs_pool, job_executator

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
    comment::Integer
    duration::AbstractString
    desc::AbstractString
    disc::Integer
    subject_id::Integer
end

const DEFAULT_CONFIG_FILE = joinpath(
    dirname(dirname(pathof(@__MODULE__))), "data", "config.toml")
config = parsefile(DEFAULT_CONFIG_FILE)

include("utils.jl")
include("database.jl")
include("schedule.jl")
using .Schedule

end
