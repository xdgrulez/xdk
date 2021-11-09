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
   
   Helpers(addHandlers e2V vs2S changeSuffix) at 'Helpers.ozf'

   Principles(principles) at 'Solver/Principles/Principles.ozf'
   Outputs(outputs) at 'Outputs/Outputs.ozf'
   Compiler(files2SLE sLE2File) at 'Compiler/Compiler.ozf'
define
   {Helpers.addHandlers}
   %%
   S2A = String.toAtom
   %%
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)                  
	   
	   grammars(single type:list(string) char:&g default:nil)
	   input(single type:string char:&i default:"")
	   output(single type:string char:&o default:unit)

	   debug(single type:bool char:&d default:false)
	  )}
   %% help
   if AArgRec.help then
      {System.showError
       '*XDG Development Kit (XDK): Grammar file compiler*\n'#
       '--(no)help                   display this help\n'#
       ' -h\n'#
       '--grammars <File1,...,FileN> select grammar files\n'#
       ' -g                          (e.g. -g Acl01.ul,Acl01-2.ul\n'#
       '                              default: no files)\n'#
       '--input                      provide input\n'#
       ' -i                          (e.g. --input "peter maria liebt"\n'#
       '                              default: "")\n'#
       '--output File                specify filename for compiled grammar\n'#
       ' -o                          (e.g. -o Acl01.slp\n'#
       '                              default: name of the first\n'#
       '                             grammar file with suffix changed to ".slp")\n'#
       '--(no)debug                  toggle debug mode\n'#
       ' -d                          (default: nodebug)'
      }
      {Application.exit 1}
   end
   %% grammars
   GSs = AArgRec.grammars
   %% input
   InputS = AArgRec.input
   %% output
   OS = AArgRec.output
   %% debug
   DebugB = AArgRec.debug
   %%
   if GSs==nil then
      {System.showError 'No grammar.'}
      {Application.exit 1}
   end
   try
      PrincipleILs = Principles.principles
      OutputILs = Outputs.outputs
      GS = {Helpers.vs2S GSs}
      {System.printInfo 'Compiling grammar "'#GS#'" ... '}
      I1 = {Property.get 'time.total'}
      InputA = {S2A InputS}
      MetaX = InputA
      SLE = {Compiler.files2SLE GSs MetaX PrincipleILs OutputILs DebugB System.showError}
      I2 = {Property.get 'time.total'}
      I = I2-I1
      {System.showInfo 'done. ('#I#'ms)'}
      %%
      GS1 =
      if OS==unit then
	 GS1 = GSs.1
      in
	 {Helpers.changeSuffix GS1 "slp"}
      else
	 OS
      end
   in
      {Compiler.sLE2File SLE GS1 DebugB System.showError}
      {System.showInfo 'Saved compiled grammar as "'#GS1#'".'}
   catch E then
      V = {Helpers.e2V E}
   in
      {System.showError '\n'#V}
      if DebugB orelse V=='unhandled error' then {System.show E} end
   end
in
   {Application.exit 0}
end
