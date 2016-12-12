
using System;
using System.Linq;
using System.Collections.Generic;

using CC.Utils;

namespace CC.Parsing 
{
    public struct Empty
    {
    }

    public struct ParseBuffer<T>
    {
        public int Index;
        public T Text;

        public ParseBuffer( T text, int index )
        {
            Text = text;
            Index = index;
        }
    }

    public class FailData
    {
        public readonly int FailIndex;

        public FailData( int index )
        {
            FailIndex = index;
        }
    }

    public class ParseResult<TRes, TBuffer>
    {
        public readonly bool IsSuccessful;
        public readonly TRes Result;
        public readonly ParseBuffer Buffer;
        public readonly FailData Failure;

        public ParseResult( TRes result, ParseBuffer<TBuffer> buffer )
        {
            IsSuccessful = true;
            Result = result;
            Buffer = buffer;
        }
        public ParseResult( FailData f )
        {
            IsSuccessful = false;
            Failure = f;
        }
    }

    public delegate ParseResult<TRes> Parser<TRes, TBuffer>( ParseBuffer<TBuffer> buffer );

    public static class ParserUtil
    {
        public static Parser<B, TBuffer> Bind<A, B, TBuffer>( Parser<A, TBuffer> parser, Func<A, Parser<B, TBuffer>> gen )
        {
            return buffer => 
            {
                var result = parser( buffer );
                if ( result.IsSuccessful )
                {
                    return gen( result.Result )( result.Buffer );
                }
                else
                {
                    return new ParseResult<B>( new FailData( buffer.Index ) );
                }
            };
        }

        public static Parser<B, TBuffer> Bind<A, B, TBuffer>( Parser<A, TBuffer> parser, Func<Parser<B, TBuffer>> gen )
        {
            return buffer => 
            {
                var result = parser( buffer );
                if ( result.IsSuccessful )
                {
                    return gen()( result.Buffer );
                }
                else
                {
                    return new ParseResult<B>( new FailData( buffer.Index ) );
                }
            };
        }

        public static Parser<A, TBuffer> Unit<A, TBuffer>( A value )
        {
            return buffer => new ParseResult<A>( value, buffer );
        } 

        public static Parser<Empty, string> End = buffer =>  // TODO this can be for any TBuffer
        {
            if( buffer.Index == buffer.Text.Length )
            {
                return new ParseResult<Empty>( new Empty(), buffer );
            }
            else
            {
                return new ParseResult<Empty>( new FailData( buffer.Index ) ); 
            }
        };

        public static Parser<B, TBuffer> Map<A, B, TBuffer>( this Parser<A, TBuffer> parser, Func<A, B> f )
        {
            return buffer => 
            {
                var result = parser( buffer );
                if ( result.IsSuccessful )
                {
                    return new ParseResult<B>( f( result.Result ), result.Buffer );
                }
                else
                {
                    return new ParseResult<B>( new FailData( buffer.Index ) ); 
                }
            };
        }

        public static Parser<Maybe<A>, TBuffer> OneOrNone<A, TBuffer>( this Parser<A, TBuffer> parser )
        {
            return buffer =>
            {
                var result = parser( buffer );
                if ( result.IsSuccessful )
                {
                    return new ParseResult<Maybe<A>>( new Maybe<A>( result.Result ), result.Buffer );
                }
                else
                {
                    return new ParseResult<Maybe<A>>( new Maybe<A>(), buffer ); 
                }
            };
        }

        public static Parser<IEnumerable<A>, TBuffer> OneOrMore<A, TBuffer>( this Parser<A, TBuffer> parser )
        {
            return Bind( parser,              v  =>
                   Bind( parser.ZeroOrMore(), vs => 
                   Unit( new A[] { v }.Concat( vs ) ) ) );
        }

        public static Parser<IEnumerable<A>, TBuffer> ZeroOrMore<A, TBuffer>( this Parser<A, TBuffer> parser )
        {
            return buffer =>
            {
                var a = new List<A>();
                var result = parser( buffer );
                ParseBuffer? temp = null;
                while ( result.IsSuccessful )
                {
                    temp = result.Buffer;
                    a.Add( result.Result );
                    result = parser( result.Buffer );
                }
                if ( temp.HasValue )
                {
                    return new ParseResult<IEnumerable<A>>( a, temp.Value );
                }
                else
                {
                    return new ParseResult<IEnumerable<A>>( a, buffer ); 
                }
            };
        }

        public static Parser<A> Alternate<A>( params Parser<A>[] parsers )
        {
            return buffer => 
            {
                foreach( var p in parsers )
                {
                    var result = p( buffer );
                    if ( result.IsSuccessful )
                    {
                        return new ParseResult<A>( result.Result, result.Buffer );
                    }
                }
                return new ParseResult<A>( new FailData( buffer.Index ) ); 
            };
        }

        public static Parser<string> ParseUntil<Ignore>( Parser<Ignore> end )
        {
            return buffer =>
            {
                var length = 0;
                var start = buffer.Index;
                var res = end( buffer );
                while ( !res.IsSuccessful && start + length < buffer.Text.Length )
                {
                    length++;
                    buffer.Index++;
                    res = end( buffer );
                }
                if ( res.IsSuccessful )
                {
                    return new ParseResult<string>( buffer.Text.Substring( start, length ), res.Buffer );
                }
                else
                {
                    return new ParseResult<string>( new FailData( buffer.Index ) );
                }
            };
        }

        public static Parser<char> EatCharIf( Func<char, bool> predicate ) 
        {
            return buffer =>
            {
                if ( buffer.Index < buffer.Text.Length && predicate( buffer.Text[buffer.Index] ) )
                {
                    var index = buffer.Index;
                    buffer.Index++;
                    return new ParseResult<char>( buffer.Text[index], buffer );
                }
                else
                {
                    return new ParseResult<char>( new FailData( buffer.Index ) ); 
                }
            };
        }

        public static Parser<char> EatChar = buffer => 
        {
            if ( buffer.Index < buffer.Text.Length )
            {
                var index = buffer.Index;
                buffer.Index++;
                return new ParseResult<char>( buffer.Text[index], buffer );
            }
            else
            {
                return new ParseResult<char>( new FailData( buffer.Index ) ); 
            }
        };

        public static Parser<string> Match( string value ) 
        {
            return buffer =>
            {
                if ( value.Length + buffer.Index <= buffer.Text.Length )
                {
                    var target = buffer.Text.Substring( buffer.Index, value.Length );
                    if ( target == value )
                    {
                        buffer.Index += value.Length;
                        return new ParseResult<string>( value, buffer );
                    }
                }
                return new ParseResult<string>( new FailData( buffer.Index ) );
            };
        }
    }
}
