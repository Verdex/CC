
require "token"

local _tokens
local _index 

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
    if tok == ct() then
        nt()
        return true
    else 
        return false
    end
end

function is( tok )
    if tok == ct() then
        nt()
    else
        error( "Expected:  " .. tok .. ", but found:  " .. ct() )
    end
end


