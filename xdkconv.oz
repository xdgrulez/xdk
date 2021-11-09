%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Application(exit getArgs)
   Property(get)
   System(showError showInfo printInfo show)
   
   Helpers(e2V) at 'Helpers.ozf'

   Converter(convert) at 'Compiler/Converter.ozf'
define
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)                  
	   
	   grammar(single type:string char:&g default:"")
	   output(single type:string char:&o default:"")

	   debug(single type:bool char:&d default:false)
	  )}
   %% help
   if AArgRec.help then
      {System.showError
       '*XDG Development Kit (XDK): Grammar file converter*\n'#
       '--(no)help                   display this help\n'#
       ' -h\n'#
       '--grammar File               source grammar file\n'#
       ' -g                          (e.g. -g Acl01.ul\n'#
       '                              default: "")\n'#
       '--output File                destination grammar file\n'#
       ' -o                          (e.g. -o Acl01.xml\n'#
       '                              default: "")\n'#
       '--(no)debug                  toggle debug mode\n'#
       ' -d                          (default: nodebug)'
      }
      {Application.exit 1}
   end
   %% grammar
   FromS = AArgRec.grammar
   %% output
   ToS = AArgRec.output
   %% debug
   DebugB = AArgRec.debug
   %% get off the ground
   if FromS=="" then
      {System.showError 'No source grammar file.'}
      {Application.exit 1}
   end
   if ToS=="" then
      {System.showError 'No destination grammar file.'}
      {Application.exit 1}
   end
   try
      {System.printInfo 'Converting grammar file "'#FromS#'" to "'#ToS#'"... '}
      I1 = {Property.get 'time.total'}
      {Converter.convert FromS ToS proc {$ X} skip end}
      I2 = {Property.get 'time.total'}
      I = I2-I1
   in
      {System.showInfo 'done. ('#I#'ms)'}
   catch E then
      V = {Helpers.e2V E}
   in
      {System.showError '\n'#V}
      if DebugB orelse V=='unhandled error' then {System.show E} end
   end
in
   {Application.exit 0}
end
