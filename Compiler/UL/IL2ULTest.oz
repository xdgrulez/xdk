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
[IL2UL] = {Link ['../../Compiler/UL/IL2UL.ozf']}
UL1 = {IL2UL.convert IL}
%%
File = {New Open.file init(name: '../../Grammars/nut1_out.ul'
			   flags: [create truncate write text])}
{File write(vs: UL1)}
{File close}
%%
{Inspect done}
