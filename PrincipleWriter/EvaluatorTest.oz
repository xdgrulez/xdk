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
Tree = {Parser.parseUrl 'Examples/order2dPW.ul'}
%%
[Typer] = {Link ['Typer.ozf']}
Tree1 = {Typer.type Tree}
%%
[Optimizer] = {Link ['Optimizer.ozf']}
Tree2 = {Optimizer.optimize Tree1 all}
%%
[Evaluator] = {Link ['Evaluator.ozf']}
DefPrinciples#TALatVTups = {Evaluator.evaluate Tree2 o}
{Inspect DefPrinciples}
{Inspect TALatVTups}
%%
{Inspect done}
