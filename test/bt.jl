println("##################################")
println("#      Test for BitTorrent       #")
println("##################################")

bdecode = Bangumis.BitTorrent.BEncode.bdecode

@testset "BEncode" begin
    @test bdecode("i32e") == 32
    @test bdecode("i-32e") == -32
    @test bdecode("i$(BigInt(typemax(Int128)) + 1)e") == BigInt(typemax(Int128)) + 1
    @test bdecode("12:qwertyuiopas") == "qwertyuiopas"
    @test bdecode("li-32e4:asdfe") == [-32, "asdf"]
    @test bdecode("d3:cow3:moo4:spami-32ee") == Dict(
        "cow" => "moo",
        "spam" => -32
    )
    @test bdecode("d4:spaml1:ai-32eee") == Dict("spam" => ["a", -32])
end

