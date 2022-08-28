using Bangumis
using Test
using Dates: DateTime
using SQLite: DB
import Logging

Logging.global_logger(Logging.ConsoleLogger(stdout, Logging.Debug))
cd(dirname(dirname(pathof(Bangumis))))

@testset "Utils" begin
    @test Bangumis.Utils.date_parse("2022-02-01") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022-02") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022") == DateTime(2022, 01, 01)
    @test Bangumis.Utils.date_parse("31.07.2022") == DateTime(2022, 07, 31)
    @test Bangumis.Utils.date_parse("fdjkalsjfdklas") == DateTime(1970)
    @test Bangumis.Utils.date_parse("0") == DateTime(0)
end

@testset "Config" begin
    @test haskey(Bangumis.config, "index")
    @test haskey(Bangumis.config, "mikan")
    @test haskey(Bangumis.config, "bangumi")
    @test haskey(Bangumis.config, "aria2")
end

@testset "Database" begin
    @test Bangumis.DB.prepare_db() isa DB
    subject_db = Bangumis.DB.prepare_db("test/testcases/database/db_case1.sqlite3")
    @test subject_db isa DB
    @test Bangumis.DB.verify_db_table(subject_db, "SUBJECT_CASE", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(subject_db, "EMPTY_CASE_1", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(subject_db, "SUBJECT_WITH_DEFAULT_CASE_1", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(subject_db, "SUBJECT_WRONG_KEYS_CASE1", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(subject_db, "SUBJECT_WRONG_KEYS_CASE2", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(subject_db, "SUBJECT_WRONG_TYPE_CASE1", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(subject_db, "SUBJECT_WRONG_TYPE_CASE2", Bangumis.DB.SUBJECTS_TBL_DF)
end
