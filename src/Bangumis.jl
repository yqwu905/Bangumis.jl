module Bangumis

using TOML: parsefile

export config

config = parsefile("data/config.toml")

include("utils.jl")

end
