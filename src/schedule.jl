module Schedule

using Base
using Bangumis: config

export Job, Result, create_jobs_pool, job_executator

# Define a job to be executed by executator asynchronously.
# `id`
struct Job
    id::Integer
    f::Function
    params::Tuple
    err::Integer
    callback::Union{Job,Missing}
end

struct Result
    id::Integer
    success::Bool
    res::Any
    callback::Union{Job,Missing}
end

Base.show(io::IO, j::Job) = print(io, "Job $(j.id) $(String(Symbol(j.f)))($(join(j.params, ", "))), Callback: $(ismissing(j.callback) ? "None" : j.callback.id)")
Base.show(io::IO, r::Result) = print(io, "Job $(r.id) $(r.success ? "successed" * ", Result: " * string(r.res) : "failed"), Callback: $(ismissing(r.callback) ? "None" : String(Symbol(r.callback.f)))")

Job(id::Integer, f::Function) = Job(id, f, (), 0, missing)
Job(id::Integer, f::Function, params::Tuple) = Job(id, f, params, 0, missing)
Job(id::Integer, f::Function, params::Tuple, callback::Union{Job,Missing}) = Job(id, f, params, 0, callback)
Job(id::Integer, f::Function, callback::Union{Job,Missing}) = Job(id, f, (), 0, callback)
create_jobs_pool(size::Integer=1000) = (Channel{Job}(size), Channel{Result}(size))

function job_executator(id::Integer, pool::Channel{Job}, res::Channel{Result}, max_retries::Integer=5)
    @info "Executor $id started."
    for job in pool
        try
            r = job.f(job.params...)
            put!(res, Result(job.id, true, r, job.callback))
        catch e
            if (job.err < max_retries)
                @warn "$job failed: $e, Retry $(job.err)/$max_retries"
                put!(pool, Job(job.id, job.f, job.params, job.err + 1, job.callback))
            else
                @error "$job failed: $e, max retries exceed, stop executing."
                put!(res, Result(job.id, false, missing, job.callback))
            end
        end
    end
    @info "Executor $id terminated."
end

pool, res = create_jobs_pool(config["base"]["pool_size"])
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
        pool, res = create_jobs_pool(config["base"]["pool_size"])
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
