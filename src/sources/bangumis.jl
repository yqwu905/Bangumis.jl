module Bangumis

using Dates: dayofweek
using ...Bangumis.Utils: http_get, date_parse, parse
using ...Bangumis: Subject
using JSON

const BASE_URL = "https://api.bgm.tv"

"""
    index_sub(id)
Get subject by index from bangumi.tv.
"""
function index_sub(id::Integer)::Union{Missing, Subject}
    r = parse(http_get("$BASE_URL/v0/subjects/$id"))
    if (isempty(r))
        return missing 
    end
    air_date = date_parse(get(r, "date", "1970-1-1"))
    Subject(
        r["id"],
        "https://bangumi.tv/subject/$id",
        r["type"],
        r["name"],
        r["name_cn"],
        r["summary"],
        air_date,
        dayofweek(air_date),
        (
            large=r["images"]["large"],
            common=r["images"]["common"],
            medium=r["images"]["medium"],
            small=r["images"]["small"],
            grid=r["images"]["grid"]
        )
    )
end

end
