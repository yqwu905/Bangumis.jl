module Bangumis

using TOML: parsefile
using Dates: DateTime

export config, Subject, Episode, start_main_thread, close_main_thread

struct Subject
    id::Integer
    url::AbstractString
    type::Int
    name::AbstractString
    name_cn::AbstractString
    summary::AbstractString
    air_date::DateTime
    air_weekday::Integer
    images::NamedTuple{(:large, :common, :medium, :small, :grid),Tuple{AbstractString,AbstractString,AbstractString,AbstractString,AbstractString}}
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

const DEFAULT_CONFIG_FILE = joinpath(
    dirname(dirname(pathof(@__MODULE__))), "data", "config.toml")
const config = Dict(Iterators.map(f, parsefile(DEFAULT_CONFIG_FILE)))

include("utils.jl")
using .Utils
export http_get
include("database.jl")
include("schedule.jl")
include("test.jl")
using .Schedule
export Job, Result, create_jobs_pool, job_executator
include("sources.jl")
include("BT/bittorrent.jl")

pool, res = Bangumis.Schedule.create_jobs_pool(config["base"]["pool_size"])
dump_res = Channel{Result}(100000)
executators = Task[]

function daemon(pool::Channel{Job}, result::Channel{Result})
    @info "Daemon thread started."
    for res in result
        if (ismissing(res.callback))
            @debug "$res ended."
            push!(dump_res, res)
        elseif res.success
            @debug "Add new job $(res.callback) for parent job $(res.id)"
            put!(pool, Job(res.callback.id, res.callback.f, (res.res..., res.callback.params...), res.callback.callback))
        else
            @warn "Job $(res.id) failed, any callback job will be prevent."
            push!(dump_res, res)
        end
    end
    @info "Daemon thread terminated."
end

function start_main_thread()
    global pool, res, executators
    executators = Task[]
    if (!isopen(pool))
        pool, res = Bangumis.Schedule.create_jobs_pool(config["base"]["pool_size"])
    end
    @info "Main thread started."
    @info "Starting $(config["base"]["async"]) executators..."
    for i in 1:config["base"]["async"]
        push!(executators, @async job_executator(i, pool, res))
    end
    @async daemon(pool, res)
end

function close_main_thread()
    global pool, res
    close(pool)
    for i in pool
        @debug "Drop job $i"
    end
    for executator in executators
        wait(executator)
    end
    close(res)
    for i in res
        @debug "Drop result $i"
    end
    @info "Main thread terminated."
end

end
