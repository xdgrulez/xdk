%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Application(getArgs exit)
   System(showError)
   
   Helpers(getLines putV) at 'Helpers.ozf'
define
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)
	   input(single type:string char:&i default:"")
	   examples(single type:string char:&e default:"")
	   output(single type:string char:&o default:""))}
    
   %%
   if AArgRec.help then
      {System.showError
       '--(no)help               display this help\n'#
       ' -h\n'#
       '--input File             input lem evaluation *.txt file\n'#
       ' -i                      (e.g. -i lem_evaluation/filter_none/wsj23_05-09_lem.txt\n'#
       '--examples File          examples *.txt file\n'#
       ' -e                      (e.g. -e lem_evaluation/wsj23_05-09_brief_nosubstitution.txt\n'#
       '                          default: "")\n'#
       '--output File            output subset lem evaluation *.txt file\n'#
       ' -o                      (e.g. -o lem_evaluation/filter_none/wsj23_05-09_lem_nosubstitution.txt\n'}
      {Application.exit 0}
   end
   %% input
   InputS = AArgRec.input
   if InputS=="" then
      {System.showError 'No input lem evaluation *.txt file.'}
      {Application.exit 1}
   end
   %% examples
   ExamplesS = AArgRec.examples
   if ExamplesS=="" then
      {System.showError 'No examples *.txt file.'}
      {Application.exit 1}
   end
   %% output
   OutputS = AArgRec.output
   if OutputS=="" then
      {System.showError 'No output lem evaluation *.txt file.'}
      {Application.exit 1}
   end
   %%
   Ss = {Helpers.getLines InputS}
   Ss1 = {Helpers.getLines ExamplesS}
   fun {CollectLines Ss AccSs}
      case Ss
      of nil then AccSs
      [] S|Ss2 then
	 Ss3 = {String.tokens S & }
      in
	 if Ss3.1=="sent:" then
	    Ss4 = {List.drop Ss3 2}
	    S1 = {FoldL Ss4
		  fun {$ AccS S} {Append AccS & |S} end ""}
	    S2 = {List.drop S1 1}
	 in
	    if {Member S2 Ss1} then
	       Ss5 = {List.drop Ss2 3}
	       Ss6 = {List.take Ss2 6}
	       Ss7 = {Filter Ss6
		      fun {$ S}
			 Ss = {String.tokens S & }
		      in
			 {Member Ss.1 ["done" "time(CPU):" "parsed"]}
		      end}
	    in
	       {CollectLines Ss5 {Append AccSs ""|S|Ss7}}
	    else
	       {CollectLines Ss2 AccSs}
	    end
	 else
	    {CollectLines Ss2 AccSs}
	 end
      end
   end
   Ss2 = {CollectLines Ss nil}
   S = {FoldL Ss2 fun {$ AccS S} {Append AccS &\n|S} end ""}
   S1 = {Append {List.drop S 2} "\n"}
in
   {Helpers.putV S1 OutputS}
   {Application.exit 0}
end
