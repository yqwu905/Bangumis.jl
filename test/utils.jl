println("##################################")
println("#      Test for Utilities        #")
println("##################################")

@testset "date_parse" begin
    @test Bangumis.Utils.date_parse("2022-02-01") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022-02") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022") == DateTime(2022, 01, 01)
    @test Bangumis.Utils.date_parse("31.07.2022") == DateTime(2022, 07, 31)
    @test Bangumis.Utils.date_parse("fdjkalsjfdklas") == DateTime(1970)
    @test Bangumis.Utils.date_parse("0") == DateTime(0)
end

@testset "missing_eq" begin
    @test Bangumis.Utils.missing_eq(missing, missing)
    @test Bangumis.Utils.missing_eq(1, 1.0)
    @test Bangumis.Utils.missing_eq(Int64(1), Int32(1))
    @test !Bangumis.Utils.missing_eq(missing, 1)
    @test !Bangumis.Utils.missing_eq(2, 1)
    @test !Bangumis.Utils.missing_eq(1, DateTime(1970))
end
