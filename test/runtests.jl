using Bangumis
using Test
using Dates: DateTime
using SQLite: DB, execute
import Logging

Logging.global_logger(Logging.ConsoleLogger(stdout, Logging.Debug))
cd(dirname(dirname(pathof(Bangumis))))
rm("test/tmp", recursive = true, force = true)
mkdir("test/tmp")
cp("test/testcases/database", "test/tmp/database")

@testset "Config" begin
    @test haskey(Bangumis.config, "index")
    @test haskey(Bangumis.config, "mikan")
    @test haskey(Bangumis.config, "bangumi")
    @test haskey(Bangumis.config, "aria2")
end

include("utils.jl")
include("database.jl")
