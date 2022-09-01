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

@testset "Utils" begin
    # date_parse
    @test Bangumis.Utils.date_parse("2022-02-01") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022-02") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022") == DateTime(2022, 01, 01)
    @test Bangumis.Utils.date_parse("31.07.2022") == DateTime(2022, 07, 31)
    @test Bangumis.Utils.date_parse("fdjkalsjfdklas") == DateTime(1970)
    @test Bangumis.Utils.date_parse("0") == DateTime(0)
    # missing_eq
    @test Bangumis.Utils.missing_eq(missing, missing)
    @test Bangumis.Utils.missing_eq(1, 1.0)
    @test Bangumis.Utils.missing_eq(Int64(1), Int32(1))
    @test !Bangumis.Utils.missing_eq(missing, 1)
    @test !Bangumis.Utils.missing_eq(2, 1)
    @test !Bangumis.Utils.missing_eq(1, DateTime(1970))
end

@testset "Config" begin
    @test haskey(Bangumis.config, "index")
    @test haskey(Bangumis.config, "mikan")
    @test haskey(Bangumis.config, "bangumi")
    @test haskey(Bangumis.config, "aria2")
end

include("test/database.jl")
