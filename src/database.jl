module DB

using SQLite
using DataFrames
using ..Bangumis: config
using ..Bangumis.Utils: missing_eq

export prepare_db

# Table Definition
const SUBJECTS_TBL_DF = DataFrame(
    cid = collect(0:12),
    name = ["id", "url", "type", "name", "name_cn", "summary", "air_date", "air_weekday", "image_large", "image_common", "image_medium", "image_small", "image_grid"],
    type = ["INTEGER", "TEXT", "INTEGER", "TEXT", "TEXT", "TEXT", "TEXT", "INTEGER", "TEXT", "TEXT", "TEXT", "TEXT", "TEXT"],
    notnull = [1, 1, 1, 1, 0, 0, 1, 1, 0, 0, 0, 0, 0],
    dflt_value = ones(Missing, 13),
    pk = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
)

const EPISODES_TBL_DF = DataFrame(
    cid = collect(0:10),
    name = ["id", "type", "name", "name_cn", "sort", "airdate", "comment", "duration", "desc", "disc", "ep"],
    type = ["INTEGER", "INTEGER", "TEXT", "TEXT", "INTEGER", "TEXT", "INTEGER", "TEXT", "TEXT", "INTEGER", "INTEGER"],
    notnull = [1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0],
    dflt_value = ones(Missing, 11),
    pk = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
)

"""
    verify_db_table(db, tbl_name, tbl_cols)
Compare table `tbl_name` structure from database `db` with given structure `tbl_cols`.
"""
function verify_db_table(db::SQLite.DB, tbl_name::AbstractString, tbl_cols::DataFrame)::Bool
    cols = DataFrame(SQLite.columns(db, tbl_name))
    if (size(cols) != size(tbl_cols))
        return false
    end
    for i in 1:size(cols, 1)
        for j in 1:size(cols, 2)
            if (!missing_eq(cols[i, j], tbl_cols[i, j]))
                @error "Database $db, Table $tbl_name mismatch require columns at ($i, $j): $(cols[i, j])::$(typeof(cols[i, j])) is given, $(tbl_cols[i, j])::$(typeof(tbl_cols[i, j])) is required."
                return false
            end
        end
    end
    @debug "Database $db, Table $tbl_name structure verified."
    return true
end

function prepare_db(filename::Union{AbstractString,Nothing} = nothing)::SQLite.DB
    if (isnothing(filename))
        filename = config["index"]["db"]
        @debug "No database specified, use default value $filename"
    else
        @debug "Using specified database file $filename"
    end
    db = SQLite.DB(filename)
end

end
