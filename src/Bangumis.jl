module Bangumis

using TOML: parsefile

export config

const DEFAULT_CONFIG_FILE = joinpath(
    dirname(dirname(pathof(@__MODULE__))), "data", "config.toml")
config = parsefile(DEFAULT_CONFIG_FILE)

include("utils.jl")
include("database.jl")

end
