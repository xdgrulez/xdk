%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(onToplevel)

   FD(is reflect)

   FD1(int) at '../../Solver/Principles/Lib/FD.ozf'
   
   Select(fd) at '../../Solver/Principles/Lib/Select.ozf'
   
   Helpers(cILIIL2AI aI2CILIIL
	   encode decode pretty mapDSpec) at 'Helpers.ozf'

   Flat(make) at 'Flat.ozf'
export
   Make
prepare
   ListToRecord = List.toRecord
   ListMapInd = List.mapInd
define
   %% Make: AIs -> Lat
   %% Makes a domain lattice with domain AIs.
   %% SL = D.
   fun {Make AIs}
      for AI in AIs do
	 if {Not ({IsAtom AI} orelse {IsInt AI})} then
	    raise error1('functor':'Compiler/Lattices/Domain.ozf' 'proc':'Make' msg:'Cannot make domain lattice because domain elements contain an element which is neither an atom nor an integer.' info:o(AIs AI) coord:noCoord file:noFile) end
	 end
      end
      %%
      FlatLat = {Flat.make}
      %% top
      Top = FlatLat.top
      %% bot
      Bot = FlatLat.bot
      %% glb
      Glb = FlatLat.glb
      %% select
      Select1 = Select.fd
      %% cardinality
      CardI = {Length AIs}
      %% DSpec
      DSpec = if CardI==0 then nil else 1#CardI end
      %% makeVar
      fun {MakeVar} {FD1.int DSpec} end
      %% encode
      %% Creates a record mapping atoms/integers AI to integers I.
      %% NB: Here we sort again although TypeCollector.oz already does
      %% that. Why? When the lattice functor is called from e.g. a
      %% principle, it is not guaranteed that the atoms are already
      %% sorted.
      AIs1 = {Sort AIs
	      fun {$ AI1 AI2}
		 if {IsInt AI1} andthen {IsAtom AI2} then true
		 elseif {IsAtom AI1} andthen {IsInt AI2} then false
		 else AI1<AI2
		 end
	      end}
      AIITups = {ListMapInd AIs1
		 fun {$ I AI} AI#I end}
      AIIRec = {ListToRecord o AIITups}
      fun {AI2I AI} AIIRec.AI end
      fun {EncodeProc IL _}
	 AI = {Helpers.cILIIL2AI IL}
	 I = {AI2I AI}
      in
	 [I]
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      %% Create a record mapping integers I to atoms/integers AI
      IAITups = {ListMapInd AIs1
		 fun {$ I AI} I#AI end}
      IAIRec = {ListToRecord o IAITups}
      fun {I2AI I} IAIRec.I end
      %%
      fun {DecodeDetProc I}
	 if I==Top then elem(tag: top)
	 elseif I==Bot then elem(tag: bot)
	 else
	    AI = {I2AI I}
	    CILIIL = {Helpers.aI2CILIIL AI}
	 in
	    CILIIL
	 end
      end
      fun {DecodeNonDetProc D}
	 DSpec = {FD.reflect.dom D}
	 DSpec1 = {Helpers.mapDSpec DSpec I2AI}
	 IL = elem(tag: '_'
		   args: [DSpec1])
      in
	 IL
      end
      fun {Decode SL}
	 {Helpers.decode SL DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc I AbbrB}
	 {I2AI I}
      end
      fun {PrettyNonDetProc D AbbrB}
	 I = {FD.reflect.size D}
      in
	 if I>50 then
	    DSpec = {FD.reflect.dom D}
	    DSpec1 = {Helpers.mapDSpec DSpec I2AI}
	 in
	    '_'(DSpec1)
	 else
	    Is = {FD.reflect.domList D}
	    AIs = {Map Is I2AI}
	 in
	    '_'(AIs)
	 end
      end
      fun {Pretty SL AbbrB}
	 {Helpers.pretty SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      end
      %% count
      fun {Count}
	 o(fd: 1
	   fs: 0)
      end
      %% build lattice
      Lat =
      elem(tag: domain
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
	   constants: AIs1
	   card: CardI
	   dSpec: DSpec
	   aI2I: AI2I
	   i2AI: I2AI
	   %%
	   encodeProc: EncodeProc)
   in
      Lat
   end
end
