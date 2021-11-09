%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Application(exit getArgs)
   Inspector(inspect)
   Property(put)
   System(showError)

   Helpers(getLines) at 'Helpers.ozf'
   SolutionViewer(view) at 'SolutionViewer.ozf'
   
   SolutionParser(parse) at 'Parsers/SolutionParser.ozf'
prepare
   ListPartition = List.partition
   ListToRecord = List.toRecord
define
   {Property.put 'print.depth' 10000}
   {Property.put 'print.width' 10000}
   %%
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)
	   solution(single type:string char:&s default:unit)
	  )}
   %%
   if AArgRec.help then
      {System.showError
       '--(no)help                   display this help\n'#
       ' -h\n'#
       '--solution <File>            solution file\n'#
       ' -s                          (e.g. --solution "csp_sol1.txt")'
      }
      {Application.exit 0}
   end
   %%
   Ss = {Helpers.getLines AArgRec.solution}
   ModelSs
   SolSs
   %% example model line:
   %%   % [1 entryIndex var#2]
   %% example solution line:
   %%   172#fd#[0]
   {ListPartition Ss
    fun {$ S} S.1==&% end ModelSs SolSs}
   SolSsI = {Length SolSs}
   FsISpecTups =
   for S in SolSs I in 1..SolSsI collect:Collect do
      X = {SolutionParser.parse S}
   in
      case X
      of I#fs#LSpec#_#_ then
	 {Collect I#LSpec}
      else
	 skip
      end
      if I mod 1000==0 then {Inspector.inspect I#'/'#SolSsI} end
   end
   FsISpecRec = {ListToRecord o FsISpecTups}
   DeleteProc = proc {$} {Application.exit 0} end
in
   {SolutionViewer.view 1 FsISpecRec ModelSs DeleteProc}
end
