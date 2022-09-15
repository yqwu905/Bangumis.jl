println("##################################")
println("#      Test for Schedule         #")
println("##################################")

start_main_thread()

cases = 1:1000
for i in cases
    j1 = Job(i, Bangumis.Test.addone)
    j = Job(i, Bangumis.Test.power, (i,), j1)
    push!(Bangumis.pool, j)
end
expected_output = map(x->x^2+1, cases)
output = Vector{Union{Missing, Integer}}(missing, length(cases))
for i in cases
    res = take!(Bangumis.dump_res)
    output[res.id] = res.res
end

@test expected_output==output
