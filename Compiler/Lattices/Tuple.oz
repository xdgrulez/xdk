%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)
%   System(show)
   
   FD(reflect)

   FD1(int minus times plus divI modI) at '../../Solver/Principles/Lib/FD.ozf'
   
   Select(fd) at '../../Solver/Principles/Lib/Select.ozf'
   
   Helpers(cILIIL2AI aI2CILIIL
	   sum sumDs prod encode decode glb
	   pretty mapDSpec
	   crunchTups multiply) at 'Helpers.ozf'
   
   Flat(make) at 'Flat.ozf'
export
   Make
prepare
   ListMapInd = List.mapInd
   ListToTuple = List.toTuple
define
   %% Make: Lats -> Lat
   %% Makes a tuple lattice with domains Lats.
   %% SL = D (if all Lats are domain lattices).
   fun {Make Lats}
      for Lat in Lats do
	 TagA = Lat.tag
      in
	 if {Not TagA==domain} then
	    raise error1('functor':'Compiler/Lattices/Tuple.ozf' 'proc':'Make' msg:'All projections of a tuple must be finite domains, and cannot of type: '#TagA info:o(Lats) coord:noCoord file:noFile) end
	 end
      end
      {MakeDomainTuple Lats}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% MakeDomainTuple: Lats -> Lat
   %% Makes a domain tuple lattice with domains Lats (where Lats are
   %% domain lattices).  SL = D.
   fun {MakeDomainTuple DomainLats}
      FlatLat = {Flat.make}
      %% top
      Top = FlatLat.top
      %% bot
      Bot = FlatLat.bot
      %% glb
      Glb = FlatLat.glb
      %% select
      fun {Select1 Is D} {Select.fd Is D} end
      %% cardinality
      %% get the cardinalities of the individual domain lattices
      %%  CardIs = [CardI_1 ... CardI_n]
      CardIs = {Map DomainLats fun {$ DomainLat} DomainLat.card end}   
      %% the cardinality of the domain product is
      %% the product of the cardinalities of the individual domain lattices
      CardI = {Helpers.prod CardIs}
      %% DSpec
      DSpec = if CardI==0 then nil else 1#CardI end
      %% makeVar
      fun {MakeVar} {FD1.int DSpec} end
      %% (list of divisors)
      %% create list of pairs _#CardI of a future _ and the cardinality CardI
      DivICardITups = {Map CardIs fun {$ CardI} _#CardI end}
      %% bind the futures to their corresponding divisors
      %%  [CardI^2 * CardI^3 * ... * CardI^n * 1  = DivI_1
      %%             CardI^3 * ... * CardI^n * 1  = DivI_2
      %%   ...
      %%                             CardI^n * 1  = DivI_(n-1)
      %%                                       1] = DivI_n
      _ = {FoldR DivICardITups
	   fun {$ DivI#CardI AccI}
	      DivI = AccI
	      CardI*AccI
	   end 1}
      %% extract the list of divisors DivIs from DivICardITups
      %%  DivIs = [DivI_1 ... DivI_n]
      DivIs = {Map DivICardITups fun {$ DivI#_} DivI end}
      %% encode
      fun {AIs2I AIs}
	 %% addends
	 %% create list Is of addends for the encoding.
	 %%  for AIs = [AI_1 ... AI_n], this is:
	 %%  [(aI2I(AI_1)-1) * DivI_1
	 %%   ...
	 %%   (aI2I(AI_n)-1) * DivI_n]
	 Is = {ListMapInd AIs
	       fun {$ I AI}
		  DomainLat = {Nth DomainLats I}
		  I1 = {DomainLat.aI2I AI}-1
		  DivI = {Nth DivIs I}
	       in
		  I1*DivI
	       end}
	 %% sum
	 %% sum up the list of addends to get the encoding of IL
	 I = {Helpers.sum Is}
      in
	 I+1
      end
      %%
      fun {Ds2D Ds}
	 %% addends
	 %% create list Is of addends for the encoding.
	 %%  for Ds = [D_1 ... D_n], this is:
	 %%  [(D_1-1) * DivI_1
	 %%   ...
	 %%   (D_n-1) * DivI_n]
	 Ds1 = {ListMapInd Ds
		fun {$ I D}
		   D1 = {FD1.minus D 1}
		   DivI = {Nth DivIs I}
		in
		   {FD1.times D1 DivI}
		end}
	 %% sum
	 %% sum up the list of addends to get the encoding of IL
	 D = {Helpers.sumDs Ds1}
      in
	 {FD1.plus D 1}
      end
      %%
      fun {EncodeProc IL _}
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
      in
	 case IL
	 of elem(tag: list
		 args: Args ...) then
	    AIs = {Map Args Helpers.cILIIL2AI}
	    I = {AIs2I AIs}
	 in
	    [I]
	 else
	    raise error1('functor':'Compiler/Lattices/Tuple.ozf' 'proc':'EncodeProc (MakeDomainTuple)' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
	 end
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {I2AIs I}
	 I1 = I-1
	 %% (decode to list of integers) create list of pairs _#DivI
	 %% of a future _ and a divisor DivI
	 DecIDivITups = {Map DivIs fun {$ DivI} _#DivI end}
	 %% bind the futures to the decoded integers for the
	 %% respective tuple position
	 _ = {FoldL DecIDivITups
	      fun {$ AccI DecI#DivI}
		 DecI = (AccI div DivI)+1
		 AccI mod DivI
	      end I1}
	 %% decode individual integers
	 AIs =
	 {ListMapInd DecIDivITups
	  fun {$ I DecI#_}
	     DomainLat = {Nth DomainLats I}
	     AI = {DomainLat.i2AI DecI}
	  in
	     AI
	  end}
      in
	 AIs
      end
      %%
      fun {D2Ds D}
	 D1 = {FD1.minus D 1}
	 %% (decode to list of fd integers) create list of pairs
	 %% _#DivI of a future _ and a divisor DivI
	 DecDDivITups = {Map DivIs fun {$ DivI} _#DivI end}
	 %% bind the futures to the decoded fd integers for the
	 %% respective tuple position
	 _ = {FoldL DecDDivITups
	      fun {$ AccD DecD#DivI}
		 DecD = {FD1.plus {FD1.divI AccD DivI} 1}
		 {FD1.modI AccD DivI}
	      end D1}
	 %% get decoded fd integers
	 Ds =
	 {Map DecDDivITups
	  fun {$ DecD#_} DecD end}
      in
	 Ds
      end
      fun {DecodeDetProc I}
	 AIs = {I2AIs I}
	 CILIILs = {Map AIs Helpers.aI2CILIIL}
      in
	 elem(tag: list
	      args: CILIILs)
      end
      fun {DecodeNonDetProc D}
	 DSpec = {FD.reflect.dom D}
	 DSpec1 = {Helpers.mapDSpec DSpec I2AIs}
      in
	 elem(tag: '_'
	      args: [DSpec1])
      end
      fun {Decode D}
	 {Helpers.decode D DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc I AbbrB}
	 AIs = {I2AIs I}
	 Tup = {ListToTuple '#' AIs}
      in
	 Tup
      end
      fun {PrettyNonDetProc D AbbrB}
	 Is = {FD.reflect.domList D}
	 Tups = {Map Is
		 fun {$ I}
		    AIs = {I2AIs I}
		    Tup = {ListToTuple '#' AIs}
		 in
		    Tup
		 end}
      in
	 if AbbrB then
	    A = {Helpers.crunchTups Tups DomainLats}
	 in
	    '_'(A)
	 else
	    '_'(Tups)
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
      elem(tag: domainTuple
	   top: Top
	   bot: Bot
	   glb: Glb
	   encode: Encode
	   decode: Decode
	   select: Select1
	   makeVar: MakeVar
	   pretty: Pretty
	   count: Count
	   %%
	   domains: DomainLats
	   card: CardI
	   dSpec: DSpec
	   aIs2I: AIs2I
	   ds2D: Ds2D
	   i2AIs: I2AIs
	   d2Ds: D2Ds
	   %%
	   encodeProc: EncodeProc)
   in
      Lat
   end
end
