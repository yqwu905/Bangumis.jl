using Bangumis
using Test
using Dates: DateTime

@testset "Utils" begin
    @test Bangumis.Utils.date_parse("2022-02-01") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022-02") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022") == DateTime(2022, 01, 01)
    @test Bangumis.Utils.date_parse("31.07.2022") == DateTime(2022, 07, 31)
    @test Bangumis.Utils.date_parse("2022-02-01") == DateTime(2022, 02, 01)
    @test Bangumis.Utils.date_parse("2022-02-01") == DateTime(2022, 02, 01)
end
