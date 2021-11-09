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
[ULParser] = {Link ['../../Compiler/UL/Parser.ozf']}
UL = {ULParser.parseUrl '../../Grammars/nut1.ul'}
%%
[UL2IL] = {Link ['../../Compiler/UL/UL2IL.ozf']}
IL = {UL2IL.convert UL}
%%
%{Inspect IL}
%%
{Inspect done}
