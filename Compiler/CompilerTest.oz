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
[Compiler] = {Link ['../Compiler/Compiler.ozf']}
[Principles] = {Link ['../Solver/Principles/Principles.ozf']}
[Outputs] = {Link ['../Outputs/Outputs.ozf']}
ILPrinciples = Principles.principles
ILOutputs = Outputs.outputs
SL = {Compiler.file2SLC '../Grammars/igk.ul' o ILPrinciples ILOutputs record true Inspector.inspect}
% {Inspect SL}
{Inspect done}
