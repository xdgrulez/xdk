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
[ULParser] = {Link ['../Compiler/UL/Parser.ozf']}
UL = {ULParser.parseUrl '../Grammars/nut1.ul'}
%%
[UL2IL] = {Link ['../Compiler/UL/UL2IL.ozf']}
IL = {UL2IL.convert UL}
%%
% [XMLParser] = {Link ['../Compiler/XML/Parser.ozf']}
% XML = {XMLParser.parseUrl '../Grammars/Acl01.xml'}
% %%
% [XML2IL] = {Link ['../Compiler/XML/XML2IL.ozf']}
% IL = {XML2IL.convert XML}
%%
[Principles] = {Link ['../Solver/Principles/Principles.ozf']}
[Outputs] = {Link ['../Outputs/Outputs.ozf']}
% note that this checks ALL principles in the principle library, not
% just the used ones :)
IL1 = {Adjoin IL
       elem(principles: Principles.principles
	    %%
	    outputs: Outputs.outputs)}
%%
[ILSyntax] = {Link ['../Compiler/ILSyntax.ozf']}
[SyntaxChecker] = {Link ['../Compiler/SyntaxChecker.ozf']}
{SyntaxChecker.check IL1 ILSyntax.syntax 'S'}
%%
{Inspect done}
