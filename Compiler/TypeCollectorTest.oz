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
%[XMLParser] = {Link ['../Compiler/XML/Parser.ozf']}
%XML = {XMLParser.parseUrl '../BIG/6.ExportXDG.xml'}
%%
[UL2IL] = {Link ['../Compiler/UL/UL2IL.ozf']}
IL = {UL2IL.convert UL}
%[XML2IL] = {Link ['../Compiler/XML/XML2IL.ozf']}
%IL = {XML2IL.convert XML}
%%
[Principles] = {Link ['../Solver/Principles/Principles.ozf']}
[Outputs] = {Link ['../Outputs/Outputs.ozf']}
IL1 = {Adjoin IL
       elem(principles: Principles.principles
	    %%
	    outputs: Outputs.outputs)}
%%
[TypeCollector] = {Link ['../Compiler/TypeCollector.ozf']}
IL2#TnTypeDict#AClassILRec#Entry1Tn#NodeTn#Node1Tn = {TypeCollector.collectTypes IL1 true Inspector.inspect}
%%
{Inspect done}
