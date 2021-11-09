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
       '--input File             input XDK evaluation *.xml file\n'#
       ' -i                      (e.g. -i XDK_evaluation/filter_none/wsj23_05-09_XDK.xml\n'#
       '--examples File          examples *.txt file\n'#
       ' -e                      (e.g. -e XDK_evaluation/wsj23_05-09_brief_nosubstitution.txt\n'#
       '                          default: "")\n'#
       '--output File            output subset XDK evaluation *.xml file\n'#
       ' -o                      (e.g. -o XDK_evaluation/filter_none/wsj23_05-09_XDK_nosubstition.xml\n'}
      {Application.exit 0}
   end
   %% input
   InputS = AArgRec.input
   if InputS=="" then
      {System.showError 'No input XDK evaluation *.xml file.'}
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
      {System.showError 'No output XDK evaluation *.xml file.'}
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
	 if {Length Ss3}>=3 then
	    if {Nth Ss3 3}=="<string" then
	       S1 = {Nth Ss2 2}
	       S2 = {List.drop S1 4}
	    in
	       if {Member S2 Ss1} then
		  Ss4 =
		  for S3 in Ss collect:Collect break:Break do
		     Ss5 = {String.tokens S3 & }
		  in
		     if {Length Ss5}>=3 then
			if {Nth Ss5 3}=="</string>" then
			   {Collect S3}
			   {Break}
			else
			   {Collect S3}
			end
		     else
			{Collect S3}
		     end
		  end
	       in
		  {CollectLines
		   {List.drop Ss2 {Length Ss4}-1}
		   {Append AccSs Ss4}}
	       else
		  {CollectLines Ss2 AccSs}
	       end
	    else
	       {CollectLines Ss2 AccSs}
	    end
	 else
	    {CollectLines Ss2 AccSs}
	 end
      end
   end
   Ss2 = {CollectLines Ss nil}
   Ss3 = {Append {List.take Ss 62} Ss2}
   Ss4 = {Append Ss3 {List.drop Ss {Length Ss}-16}}
   S = {FoldL Ss4 fun {$ AccS S} {Append AccS &\n|S} end ""}
   S1 = {Append {List.drop S 1} "\n"}
in
   {Helpers.putV S1 OutputS}
   {Application.exit 0}
end
