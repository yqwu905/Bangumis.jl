module DB

using SQLite
using ..Bangumis: config

export prepare_db

function prepare_db(filename::Union{AbstractString, Nothing}=nothing)::SQLite.DB
    if (isnothing(filename))
        filename = config["index"]["db"]
        @debug "No database specified, use default value $filename"
    else
        @debug "Using specified database file $filename"
    end
    db = SQLite.DB(filename)
end

end
