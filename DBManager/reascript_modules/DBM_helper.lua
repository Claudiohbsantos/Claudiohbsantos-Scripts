--[[
@noindex
--]]

function msg(...)
    local indent = 0

    local function printTable(table,tableName)
        if tableName then reaper.ShowConsoleMsg(string.rep("    ",indent)..tostring(tableName)..": \n") end
        indent = indent + 1
        for key,tableValue in pairs(table) do
            if type(tableValue) == "table" then
                printTable(tableValue,key)
            else
                reaper.ShowConsoleMsg(string.rep("    ",indent)..tostring(key).." = "..tostring(tableValue).."\n")
            end
        end
        indent = indent - 1
    end

    printTable({...})
end

function foo()
end
------- tablesw

function table.shift(list,n)
    local newList = {}
    for i,val in pairs(list) do
        newList[i + n] = val
    end
    return newList
end

function table.clear(list)
    for k in pairs(list) do
        list[k] = nil
    end
    return list
end

function table.removeDups(t)
    for i, ref in ipairs(t) do
    	if i == #t then break end
        for n = i+1, #t do
            if ref == t[n] then table.remove(t,n) ; n = n-1 end
        end
    end
    return t
end

-- function table.copy(t)
--     local copy = {}
--     for key,val in pairs(t) do
--         copy[key] = val
--     end
--     return copy
-- end

-- function table.reverse(list)
--     local newTable = {}
--     for i=#list,1,-1 do
--         table.insert(newTable,list[i])
--     end
--     return newTable
-- end

-------- Paths

