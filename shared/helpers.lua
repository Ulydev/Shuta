--math

function math.clamp(a, b, c) return math.max(math.min(b, c), a) end

function math.lerp(a, b, k) return a * (1-k) + b * k end

function math.sgn(x) return x >= 0 and 1 or -1 end

function math.to(a, b, v)
    if a > b then
        a = math.max(a - v, b)
    elseif a < b then
        a = math.min(a + v, b)
    end
    return a
end

function math.dist(x1, y1, x2, y2)
    return math.sqrt( (x1-x2)^2 + (y1-y2)^2 )
end

function math.adist(a1, a2)
    local diff = ( a2 - a1 + 180 ) % 360 - 180
    return (diff < -180) and (diff + 360) or diff
end

--table

function table.populate(source, with)
    for k, v in pairs(with) do
        if (type(v) == "table" and source[k] == nil) or type(v) ~= "table" then
            source[k] = v
        else --fill sub-table
            table.populate(source[k], v)
        end
    end
end

function table.merge(t1, t2)
    local res = {}
    table.populate(res, t1)
    table.populate(res, t2)
    return res
end