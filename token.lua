
tokenType = 
{
    ignore = "ignore";
    symbol = "symbol";
    semicolon = "semicolon";
    equal = "equal"; 
    openCurly = "openCurly";
    closeCurly = "closeCurly";
    string = "string";
    bar = "bar";
}

tokenMaps = 
{
    { 
        name = "comment";
        pattern = [[//.-%c]];
        trans = function () return { type = tokenType.ignore } end
    },

    { 
        name = "block comment";
        pattern = [[/%*.-%*/]];
        trans = function () return { type = tokenType.ignore } end
    },

    { 
        name = "double quote string";
        pattern = [[%"(.-)%"]];
        trans = function ( s ) return { type = tokenType.string; value = s[1] } end
    },

    { 
        name = "single quote string";
        pattern = [[%'(.-)%']];
        trans = function ( s ) return { type = tokenType.string; value = s[1] } end
    },

    { 
        name = "white space";
        pattern = "%s";
        trans = function () return { type = tokenType.ignore } end
    },

    {
        name = "bar";
        pattern = "|";
        trans = function () return { type = tokenType.bar } end
    },

    {
        name = "semi colon";
        pattern = ";";
        trans = function () return { type = tokenType.semicolon } end
    },

    {
        name = "equal";
        pattern = "=";
        trans = function () return { type = tokenType.equal } end
    },


    {
        name = "open curly";
        pattern = "{";
        trans = function () return { type = tokenType.openCurly } end
    },

    {
        name = "close curly";
        pattern = "}";
        trans = function () return { type = tokenType.closeCurly } end
    },

    {
        name = "symbol";
        pattern = "([_%a'][_%w']*)";
        trans = function ( s ) return { type = tokenType.symbol; value = s[1] } end
    },

}


