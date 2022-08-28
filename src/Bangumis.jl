module Bangumis

using TOML: parsefile

export config

config = parsefile("$(dirname(dirname(pathof(Bangumis))))/data/config.toml")

include("utils.jl")
include("database.jl")

end
