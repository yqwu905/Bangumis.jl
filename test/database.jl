println("##################################")
println("#      Test for Database         #")
println("##################################")
@testset "Verify Database Table Structure" begin
    @test DB(config["index"]["db"]) isa DB
    test_verify_db = DB("test/tmp/database/db_case1.sqlite3")
    @test test_verify_db isa DB
    @test Bangumis.DB.verify_db_table(test_verify_db, "SUBJECT_CASE", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "EMPTY_CASE_1", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "SUBJECT_WITH_DEFAULT_CASE_1", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "SUBJECT_WRONG_KEYS_CASE_1", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "SUBJECT_WRONG_KEYS_CASE_2", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "SUBJECT_WRONG_TYPE_CASE_1", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "SUBJECT_WRONG_TYPE_CASE_2", Bangumis.DB.SUBJECTS_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "SUBJECT_MISSING_COLS_CASE", Bangumis.DB.SUBJECTS_TBL_DF)
    @test Bangumis.DB.verify_db_table(test_verify_db, "EPISODES_CASE", Bangumis.DB.EPISODES_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "EPISODES_MISSING_COLS_CASE", Bangumis.DB.EPISODES_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "EPISODES_WITH_DEFAULT_CASE", Bangumis.DB.EPISODES_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "EPISODES_WRONG_KEY_CASE_1", Bangumis.DB.EPISODES_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "EPISODES_WRONG_KEY_CASE_2", Bangumis.DB.EPISODES_TBL_DF)
    @test !Bangumis.DB.verify_db_table(test_verify_db, "EPISODES_WRONG_TYPE_CASE", Bangumis.DB.EPISODES_TBL_DF)
    test_create_db = DB("test/tmp/database/create_db_1.sqlite3")
    execute(test_create_db, Bangumis.DB.generate_create_tbl_statement("EPISODES", Bangumis.DB.EPISODES_TBL_DF))
    execute(test_create_db, Bangumis.DB.generate_create_tbl_statement("SUBJECTS", Bangumis.DB.SUBJECTS_TBL_DF))
    @test Bangumis.DB.verify_db_table(test_create_db, "EPISODES", Bangumis.DB.EPISODES_TBL_DF)
    @test Bangumis.DB.verify_db_table(test_create_db, "SUBJECTS", Bangumis.DB.SUBJECTS_TBL_DF)
    test_prepare_db = Bangumis.DB.prepare_db("test/tmp/database/tmp_create_db_2")
    @test Bangumis.DB.verify_db_table(test_prepare_db, "EPISODES", Bangumis.DB.EPISODES_TBL_DF)
    @test Bangumis.DB.verify_db_table(test_prepare_db, "SUBJECTS", Bangumis.DB.SUBJECTS_TBL_DF)
    test_prepare_db2 = Bangumis.DB.prepare_db("test/tmp/database/db_case2.sqlite3")
    @test Bangumis.DB.verify_db_table(test_prepare_db2, "EPISODES", Bangumis.DB.EPISODES_TBL_DF)
    @test Bangumis.DB.verify_db_table(test_prepare_db2, "SUBJECTS", Bangumis.DB.SUBJECTS_TBL_DF)
    test_prepare_db3 = Bangumis.DB.prepare_db("test/tmp/database/db_case3.sqlite3")
    @test Bangumis.DB.verify_db_table(test_prepare_db3, "EPISODES", Bangumis.DB.EPISODES_TBL_DF)
    @test Bangumis.DB.verify_db_table(test_prepare_db3, "SUBJECTS", Bangumis.DB.SUBJECTS_TBL_DF)
    test_prepare_db4 = Bangumis.DB.prepare_db("test/tmp/database/db_case4.sqlite3")
    @test Bangumis.DB.verify_db_table(test_prepare_db3, "EPISODES", Bangumis.DB.EPISODES_TBL_DF)
    @test Bangumis.DB.verify_db_table(test_prepare_db3, "SUBJECTS", Bangumis.DB.SUBJECTS_TBL_DF)
    @test_throws Bangumis.DB.DatabaseError Bangumis.DB.prepare_db("test/tmp/database/db_case5.sqlite3")
    @test_throws Bangumis.DB.DatabaseError Bangumis.DB.prepare_db("test/tmp/database/db_case6.sqlite3")
end
