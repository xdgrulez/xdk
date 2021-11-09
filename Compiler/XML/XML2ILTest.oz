declare
fun {ErrorFormatter E}
   {Inspect E}
   error(kind: error1
	 msg: E.'functor'#', '#E.'proc'#', '#E.msg#' ('#E.coord#')'#' ('#E.file#')')
end
{Inspect start}
%%
{Error.registerFormatter error1 ErrorFormatter}
%%
[XMLParser] = {Link ['../../Compiler/XML/Parser.ozf']}
Elements = {XMLParser.parseUrl '../../Grammars/Acl01.xml'}
%%
[XML2IL] = {Link ['../../Compiler/XML/XML2IL.ozf']}
IL = {XML2IL.convert Elements}
%%
%{Inspect IL}
%%
{Inspect done}
