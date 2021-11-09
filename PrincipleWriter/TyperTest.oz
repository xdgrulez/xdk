declare
fun {ErrorFormatter E}
   {Inspect E}
   error(kind: error1
	 msg: E.'functor'#', '#E.'proc'#', '#E.msg#' ('#E.coord#')'#' ('#E.file#')')
end
{Inspector.configure widgetShowStrings true}
{Inspector.configure widgetTreeDepth 50}
%%
{Inspect start}
%%
{Error.registerFormatter error1 ErrorFormatter}
%%
[Parser] = {Link ['Parser.ozf']}
Tree = {Parser.parseUrl 'Examples/orderPW.ul'}
%{Inspect Tree}
%%
[Typer] = {Link ['Typer.ozf']}
Tree1 = {Typer.type Tree}
{Inspect Tree1}
%%
{Inspect done}
