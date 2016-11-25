
Utils = Utils/Maybe.cs Utils/DisplayArray.cs Utils/Extend.cs
Parsing = Parsing/ParserUtils.cs Parsing/LangParser.cs


Test.exe : 
	dmcs $(Utils) $(Ast) $(Parsing) Main.cs -out:Test.exe

test :
	rm -rf *.exe
	dmcs $(Utils) $(Ast) $(Parsing) $(TestFramework) $(ParsingTests) Test.cs -out:Test.exe
	mono Test.exe

clean : 
	rm -rf *.exe
