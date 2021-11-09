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
[Parser] = {Link ['Parser.ozf']}
Tree = {Parser.parseUrl 'Examples/testPW.ul'}
{Inspect Tree}
%%
{Inspect done}
