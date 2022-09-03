module Schedule

using Base
using Bangumis: config

export Job, Result, create_jobs_pool, job_executator

struct Job
    id::Integer
    f::Function
    params::Tuple
    err::Integer
    callback::Function
end

struct Result
    id::Integer
    success::Bool
    res::Any
    callback::Function
end

Base.show(io::IO, j::Job) = print(io, "Job $(j.id) $(String(Symbol(j.f)))($(join(j.params, ", "))), Callback: $(String(Symbol(j.callback)))")

Job(id::Integer, f::Function, params::Tuple, callback::Function) = Job(id, f, params, 0, callback)
Job(id::Integer, f::Function, callback::Function) = Job(id, f, (), 0, callback)
create_jobs_pool(size::Integer = 1000) = (Channel{Job}(size), Channel{Result}(size))

function job_executator(pool::Channel{Job}, res::Channel{Result}, max_retries::Integer = 5)
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
end

end
