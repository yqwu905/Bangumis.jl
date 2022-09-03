module Schedule

using Base
using Bangumis: config

export Job, Result, create_jobs_pool, job_executator

struct Job
    id::Integer
    f::Function
    params::Tuple
    err::Integer
end

struct Result
    id::Integer
    success::Bool
    res::Any
end

Base.show(io::IO, j::Job) = print(io, "Job $(j.id) $(String(Symbol(j.f)))($(join(j.params, ", ")))")

Job(id::Integer, f::Function, params::Tuple) = Job(id, f, params, 0)
Job(id::Integer, f::Function) = Job(id, f, ())
create_jobs_pool(size::Integer = 1000) = Channel{Job}(size)

function job_executator(pool::Channel{Job}, res::Channel{Result}, max_retries::Integer = 5)
    for job in pool
        try
            r = job.f(job.params...)
            put!(res, Result(job.id, true, r))
        catch e
            max_retries = config["base"]["max_retries"]
            if (job.err < max_retries)
                @warn "$job failed: $e, Retry $(job.err)/$max_retries"
                put!(pool, Job(job.id, job.f, job.params, job.err + 1))
            else
                @error "$job failed: $e, max retries exceed, stop executing."
                put!(res, Result(job.id, false, missing))
            end
        end
    end
end

end
