%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Application(getArgs exit)
   Pickle(load saveCompressed)
   System(showError showInfo)
   
   Helpers(fileExists) at 'Helpers.ozf'
   PTBExamplesExtractor(extract) at 'PTBExamplesExtractor.ozf'
define
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)
	   pos(single type:string char:&p default:"")
	   minlength(single type:int char:&i default:1)
	   maxlength(single type:int char:&a default:100)
	   substitution(single type:bool char:&s default:false)
	   brief(single type:bool char:&b default:false))}
    
   %%
   if AArgRec.help then
      {System.showError
       '--(no)help               display this help\n'#
       ' -h\n'#
       '--pos File               Penn Treebank *.pos file\n'#
       ' -p                      (e.g. -p wsj_1796.pos\n'#
       '                          default: "")\n'#
       '--minlength <Int>        set minimum sentence length\n'#
       ' -i                      (e.g. -i 10\n'#
       '                          default: 1)\n'#
       '--maxlength <Int>        set maximum sentence length\n'#
       ' -a                      (e.g. -a 20\n'#
       '                          default: 100)\n'#
       '--substitution           POS-based substitution of unknown words\n'#
       ' -s                      (default: nosubstitution)\n'#
       '--(no)brief              suppress printing out additional info\n'#
       ' -b                      (default: nobrief)'}
      {Application.exit 0}
   end
   %% pos
   PosS = AArgRec.pos
   if PosS=="" then
      {System.showError 'No *.pos file.'}
      {Application.exit 1}
   end
   %% minlength
   MinlengthI = AArgRec.minlength
   %% maxlength
   MaxlengthI = AArgRec.maxlength
   %% substitution
   SubstitutionB = AArgRec.substitution
   %% brief
   BriefB = AArgRec.brief
   %%
   CachedPosS = {Append PosS ".ozp"}
   %%
   SITups =
   if {Helpers.fileExists CachedPosS} then
      {Pickle.load CachedPosS}
   else
      SITups1 = {PTBExamplesExtractor.extract PosS SubstitutionB}
   in
      {Pickle.saveCompressed SITups1 CachedPosS 9}
      SITups1
   end
   %%
   SITups1 = {Filter SITups
	      fun {$ _#I}
		 {Not I<MinlengthI} andthen {Not I>MaxlengthI}
	      end}
in
   for S#I in SITups1 I1 in 1..{Length SITups1} do
      if {Not BriefB} then {System.showInfo '* '#I1#', '#I} end
      {System.showInfo S}
   end
   {Application.exit 0}
end
