module DB

using SQLite
using ..Bangumis: config

export prepare_db

function verify_db_table(db::SQLite.DB, tbl_name::AbstractString, tbl_cols::DataFrame)::Bool
    cols = DataFrame(SQLite.columns(db, tbl_name))
    if (size(cols)!=size(tbl_cols))
        return false
    end
    for i in 1:size(cols, 1)
        for j in 1:size(cols, 2)
            if (cols[i, j]!==tbl_cols[i, j])
                @error "Database $db mismatch require columns at ($i, $j): $(cols[i, j]) is given, $(tbl_cols[i, j]) is required."
                return false
            end
        end
    end
    return true
end

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
