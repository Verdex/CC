
tokenType = 
{
    ignore = "ignore";
    int = "int";
    float = "float";
    string = "string";
    symbol = "symbol";
    dot = "dot";
    semicolon = "semicolon";
    colon = "colon";
    equal = "equal"; 
    notEqual = "notEqual";
    assign = "assign";
    mult = "mult";
    add = "add";
    sub = "sub";
    div = "div";
    openAngle = "openAngle";
    closeAngle = "closeAngle";
    openParen = "openParen";
    closeParen = "closeParen";
    openCurly = "openCurly";
    closeCurly = "closeCurly";
    openSquare = "openSquare";
    closeSquare = "closeSquare";
    comma = "comma";


    -- keywords
    enum = "enum";
    ["or"] = "or";
    ["and"] = "and";
    xor = "xor";
    ["not"] = "not";
    struct = "struct";
    ["return"] = "return";
    yieldBreak = "yieldBreak";
    yieldReturn = "yieldReturn";
    func = "func"; 
    const = "const";
    ["else"] = "else";
    ["elseif"] = "elseif"; 
    ["if"] = "if";
    ["while"] = "while";
    ["break"] = "break";
    continue = "continue";
    ["in"] = "in";
    var = "var";
    pub = "pub";
    type = "type";
    using = "using";
    module = "module";
    foreach = "foreach"; 
    ["true"] = "true";
    ["false"] = "false";
}

tokenMaps = 
{
    { 
        pattern = [[//.-%c]];
        trans = function () return { type = tokenType.ignore } end
    },

    { 
        pattern = [[/%*.-%*/]];
        trans = function () return { type = tokenType.ignore } end
    },

    { 
        pattern = [[%"(.-)%"]];
        trans = function ( s ) return { type = tokenType.string; value = s[1] } end
    },

    { 
        pattern = "%s";
        trans = function () return { type = tokenType.ignore } end
    },

    -- keywords
    {
        pattern = "true";
        trans = function () return { type = tokenType["true"] } end 
    },

    {
        pattern = "false";
        trans = function () return { type = tokenType["false"] } end 
    },

    {
        pattern = "do";
        trans = function () return { type = tokenType["do"] } end 
    },

    {
        pattern = "unit";
        trans = function () return { type = tokenType["unit"] } end 
    },

    {
        pattern = "enum";
        trans = function () return { type = tokenType["enum"] } end 
    },

    {
        pattern = "or";
        trans = function () return { type = tokenType["or"] } end 
    },

    {
        pattern = "and";
        trans = function () return { type = tokenType["and"] } end 
    },

    {
        pattern = "xor";
        trans = function () return { type = tokenType["xor"] } end 
    },

    {
        pattern = "not";
        trans = function () return { type = tokenType["not"] } end 
    },

    {
        pattern = "struct";
        trans = function () return { type = tokenType["struct"] } end 
    },

    {
        pattern = "return";
        trans = function () return { type = tokenType["return"] } end 
    },

    {
        pattern = "yield(%s+)return";
        trans = function () return { type = tokenType["yieldReturn"] } end 
    },

    {
        pattern = "yield(%s+)break";
        trans = function () return { type = tokenType["yieldBreak"] } end 
    },

    {
        pattern = "func";
        trans = function () return { type = tokenType["func"] } end 
    },

    {
        pattern = "const";
        trans = function () return { type = tokenType["const"] } end 
    },

    {
        pattern = "else";
        trans = function () return { type = tokenType["else"] } end 
    },

    {
        pattern = "else(%s+)if";
        trans = function () return { type = tokenType["elseif"] } end 
    },

    {
        pattern = "if";
        trans = function () return { type = tokenType["if"] } end 
    },

    {
        pattern = "while";
        trans = function () return { type = tokenType["while"] } end 
    },

    {
        pattern = "break";
        trans = function () return { type = tokenType["break"] } end 
    },

    {
        pattern = "continue";
        trans = function () return { type = tokenType["continue"] } end 
    },

    {
        pattern = "in";
        trans = function () return { type = tokenType["in"] } end 
    },

    {
        pattern = "var";
        trans = function () return { type = tokenType["var"] } end 
    },

    {
        pattern = "pub";
        trans = function () return { type = tokenType["pub"] } end 
    },

    {
        pattern = "type";
        trans = function () return { type = tokenType["type"] } end 
    },

    {
        pattern = "using";
        trans = function () return { type = tokenType["using"] } end 
    },

    {
        pattern = "module";
        trans = function () return { type = tokenType["module"] } end 
    },

    {
        pattern = "foreach";
        trans = function () return { type = tokenType["foreach"] } end 
    },
    -- keywords end

    { 
        pattern = "(%d+)%.(%d+)[Ee](-?%d+)";
        trans = function ( f ) 
            return { type = tokenType.float 
                   ; exponent = tonumber( f[3] ) 
                   ; intValue = tonumber( f[1] ) 
                   ; floatValue = tonumber( f[2] ) 
                   } 
        end
    },

    { 
        pattern = "(%d+)%.(%d+)";
        trans = function ( f ) 
            return { type = tokenType.float 
                   ; exponent = false
                   ; intValue = tonumber( f[1] ) 
                   ; floatValue = tonumber( f[2] ) 
                   } 
        end
    },

    { 
        pattern = "(%d+)";
        trans = function ( d ) 
            return { type = tokenType.int ; value = tonumber( d[1] ) } 
        end
    },

    {
        pattern = "%.";
        trans = function () return { type = tokenType.dot } end
    },

    {
        pattern = ",";
        trans = function () return { type = tokenType.comma } end
    },

    {
        pattern = ":";
        trans = function () return { type = tokenType.colon } end
    },

    {
        pattern = ";";
        trans = function () return { type = tokenType.semicolon } end
    },

    {
        pattern = "=";
        trans = function () return { type = tokenType.assign } end
    },

    {
        pattern = "==";
        trans = function () return { type = tokenType.equal } end
    },

    {
        pattern = "!=";
        trans = function () return { type = tokenType.notEqual } end
    },

    {
        pattern = "%*";
        trans = function () return { type = tokenType.mult } end
    },

    {
        pattern = "%+";
        trans = function () return { type = tokenType.add } end
    },

    {
        pattern = "%-";
        trans = function () return { type = tokenType.sub } end
    },

    {
        pattern = "[[/]]";
        trans = function () return { type = tokenType.div } end
    },

    {
        pattern = "<";
        trans = function () return { type = tokenType.openAngle } end
    },

    {
        pattern = ">";
        trans = function () return { type = tokenType.closeAngle } end
    },

    {
        pattern = "%[";
        trans = function () return { type = tokenType.openSquare } end
    },

    {
        pattern = "%]";
        trans = function () return { type = tokenType.closeSqure } end
    },

    {
        pattern = "{";
        trans = function () return { type = tokenType.openCurly } end
    },

    {
        pattern = "}";
        trans = function () return { type = tokenType.closeCurly } end
    },

    {
        pattern = "%(";
        trans = function () return { type = tokenType.openParen } end
    },

    {
        pattern = "%)";
        trans = function () return { type = tokenType.closeParen } end
    },

    {
        pattern = "([_%a'][_%w']*)";
        trans = function ( s ) return { type = tokenType.symbol; value = s[1] } end
    },


}


