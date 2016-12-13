
Utils = Utils/Maybe.cs Utils/DisplayArray.cs Utils/Extend.cs
Parsing = Parsing/ParserUtils.cs 


all : 
	dmcs $(Utils) $(Parsing) Main.cs -out:Test.exe

test :
	dmcs $(Utils) $(Parsing)

clean : 
	rm -rf *.exe
