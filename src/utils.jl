module Utils

using Dates: DateTime, DateFormat

export date_parse

const DATE_FORMAT = DateFormat.([
    "d.m.y",
    "y-m-dTH:M:Ss",
    "y-m-dTH:M:S"
])

function date_parse(s::AbstractString)::DateTime
    @debug "(日期解析) 输入: $s"
    d = tryparse(DateTime, s)
    if (d isa DateTime)
        return d
    end
    for df in DATE_FORMAT
        d = tryparse(DateTime, s, df)
        if (d isa DateTime)
            return d
        end
    end
    @error "无法解析日期: $s"
    return DateTime(1970)
end

function missing_eq(a, b)::Bool
    if (ismissing(a) && ismissing(b))
        return true
    elseif (ismissing(a) || ismissing(b))
        return false
    else
        return a == b
    end
end

end
