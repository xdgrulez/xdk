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
%[ULParser] = {Link ['../../Compiler/UL/Parser.ozf']}
%UL = {ULParser.parseUrl '../../Grammars/Acl01.ul'}
%%
%[UL2IL] = {Link ['../../Compiler/UL/UL2IL.ozf']}
%IL = {UL2IL.convert UL}
%%
[XMLParser] = {Link ['../../Compiler/XML/Parser.ozf']}
XML = {XMLParser.parseUrl '../../BIG/10.ExportXDG.xml'}
%%
[XML2IL] = {Link ['../../Compiler/XML/XML2IL.ozf']}
IL = {XML2IL.convert XML}
%%
[Principles] = {Link ['../../Solver/Principles/Principles.ozf']}
[Outputs] = {Link ['../../Outputs/Outputs.ozf']}
IL1 = {Adjoin IL
       elem(principles: Principles.principles
	    %%
	    outputs: Outputs.outputs)}
%%
[TypeCollector] = {Link ['../../Compiler/TypeCollector.ozf']}
IL2#TnTypeDict#AClassILTCoRec#Entry1Tn#NodeTn#Node1Tn = {TypeCollector.collectTypes IL1 true Inspector.inspect}
%%
[TypeChecker] = {Link ['../../Compiler/TypeChecker.ozf']}
IL3#AClassILTChRec#TnTypeRec = {TypeChecker.check IL2 TnTypeDict AClassILTCoRec}
%%
[LatticeMaker] = {Link ['../../Compiler/LatticeMaker.ozf']}
TnLatRec = {LatticeMaker.makeTnLatRec TnTypeRec}
%%
[Encoder] = {Link ['../../Compiler/Encoder.ozf']}
SL = {Encoder.encode IL3 TnTypeRec TnLatRec AClassILTChRec Entry1Tn NodeTn Node1Tn '' record true Inspector.inspect}
%{Inspect SL}
%%
% Entry1Tn = SL.entry1Tn
% Entry1Lat = TnLatRec.Entry1Tn
% AEntriesRec = SL.aEntriesRec
% AEntriesRecDecoded = {Record.map AEntriesRec
% 		      fun {$ Entries} {Map Entries Entry1Lat.decode} end}
% {Inspect AEntriesRecDecoded.versucht}
% Entry1Tn = SL.entry1Tn
% Entry1Lat = TnLatRec.Entry1Tn
% AEntriesRec = SL.aEntriesRec
% AEntriesRecPretty = {Record.map AEntriesRec
% 		     fun {$ Entries}
% 			{Map Entries
% 			 fun {$ Entry}
% 			    {Entry1Lat.pretty Entry true}
% 			 end}
% 		     end}
% {Inspect AEntriesRecPretty.versucht}
{Inspect done}
