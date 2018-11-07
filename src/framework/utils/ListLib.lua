local ListLib = {}
function ListLib.find(t, fn)
    for i, v in ipairs(t) do
        if fn(v) then
            return i
        end
    end
    return -1
end
function ListLib.remove(t, fn)
    local i = ListLib.find(t, fn)
    if i > 0 then
        table.remove(t, i)
        return true
    end
    return false
end
function ListLib.copy(l)
    local r = {}
    for _, i in ipairs(l) do
        table.insert(r, i)
    end
    return r
end
function ListLib.filter(l, fn)
    local r = {}
    for index, i in ipairs(l) do
        if fn(i, index) then
            table.insert(r, i)
        end
    end
    return r
end
function ListLib.append(t, t2)
    for _, item in ipairs(t2) do
        table.insert(t, item)
    end
end
function ListLib.array(...)
    local r = {}
    for i=1, select('#', ...) do
        local i = select(i, ...)
        if i then
            table.insert(r, i)
        end
    end
    return r
end
function ListLib.contains(t, v)
    for _, i in ipairs(t) do
        if i == v then
            return true
        end
    end
    return false
end

return ListLib;