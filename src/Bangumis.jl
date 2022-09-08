module Bangumis

using TOML: parsefile
using Dates: DateTime
import Logging

Logging.global_logger(Logging.ConsoleLogger(stdout, Logging.Debug))

export config, Subject, Episode, start_main_thread

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
    dirname(dirname(pathof(@__MODULE__))), "data", "conf.toml")
const config = parsefile(DEFAULT_CONFIG_FILE)

include("utils.jl")
using .Utils
export http_get
include("database.jl")
include("schedule.jl")
using .Schedule
export Job, Result, create_jobs_pool, job_executator

const pool, res = Bangumis.Schedule.create_jobs_pool(config["base"]["pool_size"])
id = 0

function daemon(pool::Channel{Job}, result::Channel{Result})
    global id
    for res in result
        if (ismissing(res.callback))
            @debug "$res ended."
        elseif res.success
            @debug "Add new job $(res.callback) for parent job $(res.id)"
            put!(pool, Job(res.callback.id, res.callback.f, (res.res..., res.callback.params...), res.callback))
        else
            @warn "Job $(res.id) failed, any callback job will be prevent."
        end
    end
end

function start_main_thread()
    global pool, res
    @info "Main thread start."
    @info "Starting $(config["base"]["async"]) executators..."
    for i in 1:config["base"]["async"]
        @async job_executator(pool, res)
        @info "Executator $i start."
    end
    @async daemon(pool, res)
    @info "Daemon thread start."
end

end
