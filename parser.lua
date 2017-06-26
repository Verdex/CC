
require "token"

local _tokens
local _index 
local _result

function init( tokens )
    _tokens = tokens
    _index = 1
end

function ct()
    return _tokens[_index]
end

function nt()
    _index = _index + 1
end

function try( tok )
    local c = ct()
    if c and tok == c.type then
        nt()
        return true
    else 
        return false
    end
end

function is( tok )
    local c = ct()
    if c and tok == c.type then
        nt()
        return true
    else
        if c ~= nil then
            error( "Expected:  " .. tok .. ", but found:  " .. c.type .. " at: " .. _index )
        else
            error( "Current token is nil at: " .. _index )
        end
    end
end

--[[
    blah = other { expr '+' expr }
         | jab   { expr '-' expr } ;

{
    type = blah
    kind = other
    1 = expr1
    2 = expr2 
]]--

function pattern()
    local finished = false
    local ret = {}

    is( tokenType.openCurly )
    repeat
        local c = ct()
        if try( tokenType.symbol ) then
            ret[#ret+1] = c
        elseif try( tokenType.string ) then

        elseif is( tokenType.closeCurly ) then
            finished = true
        else 
            error( "unknown token in pattern at:  " .. _index )
        end
    until finished

    return ret
end

function ruleOption()
    local c = ct()
    local name
    
    is( tokenType.symbol )
    name = c.value 

    local ps = pattern()
    
    return name, ps
end

function rule()
    local c = ct()
    local name

    is( tokenType.symbol )
    name = c.value

    is( tokenType.equal )

    local ret = {}
    local finished = false
    repeat
        local optionName, patterns = ruleOption()
        ret[#ret+1] = { type = name; kind = optionName; patterns = patterns }
        
        if try( tokenType.bar ) then
            
        elseif try( tokenType.semicolon ) then
            finished = true 
        else
            error( "unknown token in rule at:  " .. _index )
        end
    until finished

    return ret
end



