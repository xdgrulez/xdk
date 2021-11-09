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
   System(show showError)
   
   Helpers(getLines) at 'Helpers.ozf'
   ScriptMaker(make) at 'ScriptMaker.ozf'
   Searcher(search) at 'Searcher.ozf'
define
   {Property.put 'print.depth' 10000}
   {Property.put 'print.width' 10000}
   %%
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)
	   csp(single type:string char:&c default:unit)
	   solutions(single type:int char:&s default:9999)
	   reco(single type:int char:&r default:1)
	  )}
   %%
   if AArgRec.help then
      {System.showError
       '--(no)help                   display this help\n'#
       ' -h\n'#
       '--csp <File>                 csp output file\n'#
       ' -c                          (e.g. --csp "test.csp")\n'#
       '--solutions <Int>            set maximum number of solutions to <Int>\n'#
       ' -s                          (e.g. --solutions 4711, default: 9999)\n'#
       '--reco <Int>                 set maximum recomputation distance to <Int>\n'#
       ' -r                          (e.g. --reco 25, default: 1)'
      }
      {Application.exit 0}
   end
   %%
   CSPFileSs = {Helpers.getLines AArgRec.csp}
   %% example constraint lines:
   %%   'FS'#[value make]#[det(tuple)#[det(int)#1 det(int)#2] kinded(fset)#1]
   %% example model line:
   %%   % [1 entryIndex var#2]
   %% other lines:
   %%   % CSP for input "a b"
   %%   % id principle.graph GraphMakeNodes
   ConstraintSs = {Filter CSPFileSs fun {$ S} {Not S.1==&%} end}
   ScriptProc = {ScriptMaker.make ConstraintSs System.show}
   %%
   SolutionsI = AArgRec.solutions
   MaxRecoDistI = AArgRec.reco
   proc {OutputProc _ _} skip end
   %%
   Rec = {Searcher.search ScriptProc SolutionsI MaxRecoDistI OutputProc}
in
   {System.show search#Rec}
   {Application.exit 0}
end
