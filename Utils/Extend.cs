using System.Collections.Generic;

namespace CC.Utils
{
    public static class Extend
    {
        public static DisplayArray<T> ToDisplay<T>( this IEnumerable<T> target )
        {
            return new DisplayArray<T>( target );
        }
    }
}
