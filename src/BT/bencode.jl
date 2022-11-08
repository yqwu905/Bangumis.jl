module BEncode

using DataStructures
using ...Bangumis.Utils: dynamic_parse_int

# Type Rename
const BByteStr = Vector{UInt8}
const BInt = Integer
const BList = Vector
const BStr = String
const BDict = OrderedDict
const BObject = Union{BStr,BInt,BList,BDict,BByteStr}


"""
    bdecode(data::Vector{UInt8})::BObject

Decode byte data encode in BEncode(according to BEP3).

# Examples
```jldoctest
julia> bdecode(Vector{UInt8}("i32e")
32
```
"""
function bdecode(data::Vector{UInt8})::BObject
    first_delim = popfirst!(data)
    # Integer decode
    if (first_delim == 0x69)
        buf = UInt8[]
        delim = popfirst!(data)
        while (delim != 0x65)
            push!(buf, delim)
            delim = popfirst!(data)
        end
        return dynamic_parse_int(String(buf))
        # String decode
    elseif (first_delim >= 0x31 && first_delim <= 0x39)
        len_buf = UInt8[]
        delim = first_delim
        while (delim != 0x3a)
            push!(len_buf, delim)
            delim = popfirst!(data)
        end
        len = dynamic_parse_int(String(len_buf))
        buf = [popfirst!(data) for _ in 1:len]
        # return buf
        return String(buf)
        # List decode
    elseif (first_delim == 0x6c)
        list = BObject[]
        while (data[1] != 0x65)
            push!(list, bdecode(data))
        end
        popfirst!(data)
        return list
        # Dict decode
    elseif (first_delim == 0x64)
        dict = BDict{BObject,BObject}()
        iskey = true
        key = 0
        while (data[1] != 0x65)
            if (iskey)
                key = bdecode(data)
            else
                dict[key] = bdecode(data)
            end
            iskey = !iskey
        end
        popfirst!(data)
        return dict
    end
end

"""
    bdecode(data::AbstractString)::BObject

Decode string encode in BEncode, `data` will be convert to byte data and
decode.
"""
function bdecode(s::AbstractString)::BObject
    return bdecode(Vector{UInt8}(s))
end

end
