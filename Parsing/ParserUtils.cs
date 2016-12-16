
using System;
using System.Linq;
using System.Collections.Generic;

using CC.Utils;

namespace CC.Parsing 
{
    public struct Empty
    {
    }

    public class FailData
    {
        public readonly int FailIndex;

        public FailData( int index )
        {
            FailIndex = index;
        }
    }

    public class ParseResult<TRes>
    {
        public readonly bool IsSuccessful;
        public readonly TRes Result;
        public readonly VIter<char> Buffer;
        public readonly FailData Failure;

        public ParseResult( TRes result, VIter<char> buffer )
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

    public delegate ParseResult<TRes> Parser<TRes>( VIter<char> buffer );

    public static class ParserUtil
    {
        public static Parser<B> Bind<A, B>( Parser<A> parser, Func<A, Parser<B>> gen )
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
                    return new ParseResult<B>( new FailData( buffer.GetIndex() ) );
                }
            };
        }

        public static Parser<B> Bind<A, B>( Parser<A> parser, Func<Parser<B>> gen )
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
                    return new ParseResult<B>( new FailData( buffer.GetIndex() ) );
                }
            };
        }

        public static Parser<A> Unit<A>( A value )
        {
            return buffer => new ParseResult<A>( value, buffer );
        } 

        public static Parser<Empty> End = buffer =>  
        {
            if( buffer.End() )
            {
                return new ParseResult<Empty>( new Empty(), buffer );
            }
            else
            {
                return new ParseResult<Empty>( new FailData( buffer.GetIndex() ) ); 
            }
        };

        public static Parser<B> Map<A, B>( this Parser<A> parser, Func<A, B> f )
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
                    return new ParseResult<B>( new FailData( buffer.GetIndex() ) ); 
                }
            };
        }

        public static Parser<Maybe<A>> OneOrNone<A>( this Parser<A> parser )
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

        public static Parser<IEnumerable<A>> OneOrMore<A>( this Parser<A> parser )
        {
            return Bind( parser,              v  =>
                   Bind( parser.ZeroOrMore(), vs => 
                   Unit( new A[] { v }.Concat( vs ) ) ) );
        }

        public static Parser<IEnumerable<A>> ZeroOrMore<A>( this Parser<A> parser )
        {
            return buffer =>
            {
                var a = new List<A>();
                var result = parser( buffer );
                VIter? temp = null;
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
                return new ParseResult<A>( new FailData( buffer.GetIndex() ) ); 
            };
        }

        // TODO does this need to be a char[]?
        public static Parser<string> ParseUntil<Ignore>( Parser<Ignore> end )
        {
            return buffer =>
            {
                var ret = new StringBuilder();
                var res = end( buffer );
                while( !res.IsSuccessful && !buffer.End() )
                {
                    ret.Append( buffer.GetCurrent() );
                    buffer.MoveNext();
                    res = end( buffer );
                }
                if ( res.IsSuccessful )
                {
                    return new ParseResult<string>( ret.ToString(), res.Buffer );
                }
                else
                {
                    return new ParseResult<string>( new FailData( res.Buffer.GetIndex() ) );
                }
            };
            /*return buffer =>
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
            };*/
        }

        public static Parser<char> EatItemIf( Func<char, bool> predicate ) 
        {
            return buffer =>
            {
                var c = buffer.GetCurrent();
                if ( !buffer.End() && predicate( c ) )
                {
                    buffer.MoveNext();
                    return new ParseResult<char>( c, buffer );
                }
                else
                {
                    return new ParseResult<char>( new FailData( buffer.GetIndex() ) ); 
                }
            };
        }

    // TODO
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


// TODO can I make this into a m4 macro where i swap out all char's for something else?
