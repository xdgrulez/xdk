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
[CLLSParser] = {Link ['../../../Outputs/Lib/CLLS/Parser.ozf']}
CLLS = {CLLSParser.parseV "label(x1 '@'(x2 x3))
                           label(x2 '@'(x4 x5))
                           label(x4 anchor)
                           label(x5 lambda(x7))
                           label(x3 lambda(x6))"}
%%
{Inspect CLLS}
%%
{Inspect done}
