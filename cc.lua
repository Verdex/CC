
require 'lexer'
require 'parser'
require 'util'
require 'gen'


args = {...}

if not args[1] then
    error( "usage:  cc file.cc" )
end

f = io.open( args[1], "r" )
s = f:read("a")
l = lex( s )
p = parse( l )

print( d( p ) )
