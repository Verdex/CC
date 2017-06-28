
function d( v )
    if type( v ) == "string" then
        return '"' .. v .. '"'
    elseif type( v ) == "boolean" then
        return tostring( v )
    elseif type( v ) == "number" then
        return "" .. v
    elseif type( v ) == "table" then
        local t = {}
        for k, val in pairs( v ) do
            if type( k ) == "number" then
                t[#t+1] = d( val )
            elseif type( k ) == "string" then
                t[#t+1] = k .. " = " .. d( val )
            else 
                t[#t+1] = d( k ) .. " = " .. d( val )
            end
        end
        local listlet = table.concat( t, ", " )
        return "{ " .. listlet .. " }"
    else
        return "some " .. type( v )
    end
end
