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
Tree = {Parser.parseUrl 'Examples/treePW.ul'}
%%
[Typer] = {Link ['Typer.ozf']}
Tree1 = {Typer.type Tree}
%%
[QuadOptimizer] = {Link ['QuadOptimizer/QuadOptimizer.ozf']}
Tree2 = {QuadOptimizer.optimize Tree1 o('allow-seon':false
					'adhoc':true)}
{Inspect Tree2}
%%
{Inspect done}
