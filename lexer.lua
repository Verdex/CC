
require "token"

function lex( input )
    
    local start = 1

    local tokens = {}

    while start <= #input do

        local success = false
        for _, map in ipairs( tokenMaps ) do 
            local pattern = "^" ..  map.pattern .. "()"
            local result = { string.match( input, pattern, start ) }

            if result[1] then 

                local tok = map.trans( result ) 

                if tok.type ~= tokenType.ignore then

                    tokens[#tokens + 1] = tok
                 
                end

                start = result[#result]

                success = true
                break
            end
        end
        if not success then
            error(  "failure: " .. string.sub( input,  start - 20, start + 20 ) .. "\n" .. string.sub( input, start, start ))
        end

    end

    return tokens

end
        
function d( v )
    if type( v ) == "string" then
        return '"' .. v .. '"'
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
