%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(onToplevel)
   
   Select(fd) at '../../Solver/Principles/Lib/Select.ozf'

   Helpers(allEqual encode decode pretty glb clean) at 'Helpers.ozf'
export
   Make
define
   %% Make: U -> Lat
   %% Makes a flat lattice.
   %% SL = IL.
   fun {Make}
      %% top
      Top = 'flat_top'
      %% bot
      Bot = 'flat_bot'
      %% glb
      fun {GlbProc SL1 SL2} Bot end
      fun {Glb SL1 SL2}
	 {Helpers.glb SL1 SL2 Top GlbProc}
      end
      %% select
      %% MakeRecs: SLs -> Is#ISLRec
      %% Given a list of SL expressions SLs, create the pair
      %% Is#ISLRec, where Is is a list of integers, and ISLRec a
      %% record mapping integers to SL expressions.
      %% The procedure creates for each unique SL expression in SLs a
      %% unique integer, and the resulting list Is contains these
      %% integers instead of the corresponding SL expressions. ISLRec
      %% keeps record of which integer corresponds to which SL
      %% expression.
      %% The resulting list can be used used as the basis of the
      %% Select.fd constraint (see below).
      fun {MakeRecs SLs}
	 proc {MakeRecs1 SLs I1 I2}
	    case SLs
	    of nil then skip
	    [] SL|SLs1 then
	       ISLTups = {Dictionary.entries ISLDict}
	       FoundB =
	       for I21#SL1 in ISLTups return:Return default:false do
		  if SL==SL1 then
		     IIDict.I1 := I21
		     {Return true}
		  end
	       end
	       if {Not FoundB} then
		  IIDict.I1 := I2
		  ISLDict.I2 := SL
	       end
	       I22 = if FoundB then I2 else I2+1 end
	    in
	       {MakeRecs1 SLs1 I1+1 I22}
	    end
	 end
	 IIDict = {NewDictionary}
	 ISLDict = {NewDictionary}
	 {MakeRecs1 SLs 1 1}
	 IIRec = {Dictionary.toRecord o IIDict}
	 Is = {Record.toList IIRec}
	 ISLRec = {Dictionary.toRecord o ISLDict}
      in
	 Is#ISLRec
      end
      %%
      fun {Select1 SLs D}
	 if {System.onToplevel} then
	    _
	 else
	    Is#ISLRec = {MakeRecs SLs}
	    I = {Select.fd Is D}
	    SL
	 in
	    thread SL = ISLRec.I end
	 end
      end
      %% makeVar
      fun {MakeVar} _ end
      %% encode
      fun {EncodeProc IL _}
	 SL = {Helpers.clean IL}
      in
	 [SL]
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {DecodeDetProc SL}
	 if SL==Top then elem(tag: top)
	 elseif SL==Bot then elem(tag: bot)
	 else SL
	 end
      end
      fun {DecodeNonDetProc _}
	 elem(tag: '_'
	      args: nil) 
      end
      fun {Decode SL}
	 {Helpers.decode SL DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc SL AbbrB} SL end
      fun {PrettyNonDetProc _ AbbrB} '_' end
      fun {Pretty SL AbbrB}
	 {Helpers.pretty SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      end
      %% count
      fun {Count}
	 o(fd: 0
	   fs: 0)
      end
      %% build lattice
      Lat =
      elem(tag: flat
	   top: Top
	   bot: Bot
	   glb: Glb
	   select: Select1
	   makeVar: MakeVar
	   encode: Encode
	   decode: Decode
	   pretty: Pretty
	   count: Count
	   %%
	   encodeProc: EncodeProc)
   in
      Lat
   end
end
