module DB

using Base
using SQLite
using DataFrames
using Dates: format
using ..Bangumis: config, Episode, Subject
using ..Bangumis.Utils: missing_eq

export prepare_db, DatabaseError, push!

struct DatabaseError <: Exception
    db::SQLite.DB
    msg::AbstractString
end

Base.showerror(io::IO, e::DatabaseError) = print(io, "Database $(e.db.file): $(e.msg)")

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
    cid = collect(0:11),
    name = ["id", "type", "name", "name_cn", "sort", "airdate", "comment", "duration", "desc", "disc", "ep", "subject_id"],
    type = ["INTEGER", "INTEGER", "TEXT", "TEXT", "INTEGER", "TEXT", "INTEGER", "TEXT", "TEXT", "INTEGER", "INTEGER", "INTEGER"],
    notnull = [1, 1, 1, 0, 0, 1, 1, 1, 1, 1, 0, 1],
    dflt_value = ones(Missing, 12),
    pk = [1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
)


"""
    generate_create_tbl_statement(tbl_name, tbl_cols)
Generate sql to create table with table name `tbl_name` and columns `tbl_cols`.
"""
function generate_create_tbl_statement(tbl_name::AbstractString, tbl_cols::DataFrame)::AbstractString
    create_statement = "CREATE TABLE \"$tbl_name\"(\n"
    pk = ""
    for i in 1:size(tbl_cols, 1)
        create_statement *= "\t\"$(tbl_cols[i, :name])\"\t$(tbl_cols[i, :type])"
        if (tbl_cols[i, :notnull] == 1)
            create_statement *= "\tNOT NULL"
        end
        if (tbl_cols[i, :pk] == 1)
            pk = tbl_cols[i, :name]
        end
        create_statement *= ",\n"
    end
    create_statement *= "\tPRIMARY KEY(\"$pk\")\n)"
    return create_statement
end

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
    tbls_name = map(x -> x.name, SQLite.tables(db))
    if ("SUBJECTS" ∉ tbls_name)
        @info "SUBJECTS not exist in $db, creating."
        SQLite.execute(db, generate_create_tbl_statement("SUBJECTS", SUBJECTS_TBL_DF))
    else
        if (!verify_db_table(db, "SUBJECTS", SUBJECTS_TBL_DF))
            throw(DatabaseError(db, "Invalid SUBJECTS table structure"))
        end
    end
    if ("EPISODES" ∉ tbls_name)
        @info "EPISODES not exist in $db, creating."
        SQLite.execute(db, generate_create_tbl_statement("EPISODES", EPISODES_TBL_DF))
    else
        if (!verify_db_table(db, "EPISODES", EPISODES_TBL_DF))
            throw(DatabaseError(db, "Invalid EPISODES table structure"))
        end
    end
    db
end

function push!(db::SQLite.DB, s::Subject)
    params = (s.id, s.url, s.type, s.name, s.name_cn, s.summary, format(s.air_date, "Y-m-d"), s.air_weekday, s.images[:large], s.images[:common], s.images[:medium], s.images[:small], s.images[:grid])
    SQLite.execute(db,
        "INSERT INTO SUBJECTS VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", params
    )
end

function push!(db::SQLite.DB, ep::Episode)
    params = (ep.id, ep.type, ep.name, ep.name_cn, ep.sort, format(ep.air_date, "Y-m-d"), ep.comment, ep.duration, ep.desc, ep.disc, ep.ep, ep.subject_id)
    SQLite.execute(db,
        "INSERT INTO EPISODES VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", params
    )
end

end
