
require "token"

local _tokens
local _index 
local _result

function parse( tokens )
    init( tokens )
    local toks = tokenGroup()
    local rules = grammar()
    return toks, rules 
end

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

function done()
    return nil == _tokens[_index]
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

function look( tok )
    local c = ct()
    if c and tok == c.type then
        return true
    else 
        return false
    end
end

--[[
    blah = other { expr '+' expr }
         | jab   { expr '-' expr } ;

{
    rule = blah
    option = other
    patterns = 
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
            if try( tokenType.star ) then
                c.star = true
            elseif try( tokenType.plus ) then
                c.plus = true
            end 
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

    is( tokenType.symbol )
    local r = c.value

    is( tokenType.equal )

    local ret = {}
    local finished = false
    repeat
        local optionName, patterns = ruleOption()
        ret[#ret+1] = { option = optionName; patterns = patterns }
        
        if try( tokenType.bar ) then
            
        elseif try( tokenType.semicolon ) then
            finished = true 
        else
            error( "unknown token in rule at:  " .. _index )
        end
    until finished

    return { rule = r; options = ret }
end

function rules()
    local rs = {} 
    while not look( tokenType.closeCurly )  do
        rs[#rs+1] = rule() 
    end
    return rs
end

function grammar()
    is( tokenType.grammar )
    is( tokenType.openCurly )
    local rs = rules()
    is( tokenType.closeCurly )
    return { type = "AST" ; rules = rs }
end

function token()
    local c = ct()
    
    is( tokenType.symbol )
    local tokenName = c.value

    is( tokenType.equal )

    c = ct()

    is( tokenType.string )
    local regex = c.value

    is( tokenType.semicolon )
    
    return { token = tokenName; regex = regex }
end

function tokens()
    local ts = {} 
    while not look( tokenType.closeCurly )  do
        ts[#ts+1] = token() 
    end
    return ts
end

function tokenGroup()
    is( tokenType.token )
    is( tokenType.openCurly )
    local ts = tokens()
    is( tokenType.closeCurly )
    return { type = "token" ; tokenGroup = ts }
end

