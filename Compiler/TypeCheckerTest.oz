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
[Principles] = {Link ['../Solver/Principles/Principles.ozf']}
[Outputs] = {Link ['../Outputs/Outputs.ozf']}
IL1 = {Adjoin IL
       elem(principles: Principles.principles
	    %%
	    outputs: Outputs.outputs)}
%%
[TypeCollector] = {Link ['../Compiler/TypeCollector.ozf']}
IL2#TnTypeDict#AClassILTCoRec#Entry1Tn#NodeTn#Node1Tn = {TypeCollector.collectTypes IL1 true Inspector.inspect}
%%
[TypeChecker] = {Link ['../Compiler/TypeChecker.ozf']}
IL3#AClassILTChRec#TnTypeRec = {TypeChecker.check IL2 TnTypeDict AClassILTCoRec}
%%
{Inspect done}
