%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
%   Ozcar(breakpoint)
%   System(show)
   
   FD(sup)
   FS(sup value intersect reflect)

   FS1(var) at '../../Solver/Principles/Lib/FS.ozf'

   Select(fs) at '../../Solver/Principles/Lib/Select.ozf'

   Helpers(glb iIL2I encode i2IIL expandMSpec decode pretty) at 'Helpers.ozf'

   Flat(make) at 'Flat.ozf'
export
   Make
define
   NoneMSpec = [0]
   OneMSpec = [1]
   OptMSpec = [0#1]
   AnyMSpec = [0#FS.sup]
   GtOneMSpec = [1#FS.sup]
   %%
   NoneM = {FS.value.make NoneMSpec}
   OneM = {FS.value.make OneMSpec}
   OptM = {FS.value.make OptMSpec}
   AnyM = {FS.value.make AnyMSpec}
   GtOneM = {FS.value.make GtOneMSpec}
   %%
   %% Make: U -> Lat
   %% Makes a cardinality lattice.
   %% SL = M
   fun {Make}
      FlatLat = {Flat.make}
      %% top
      Top = NoneM
      %% bot
      Bot = FlatLat.bot
      %% glb
      GlbProc = FS.intersect
      fun {Glb M1 M2}
	 {Helpers.glb M1 M2 Top GlbProc}
      end
      %% select
      fun {Select1 Ms D} {Select.fs Ms D} end
      %% makeVar
      MakeVar = FS1.var.decl
      %% encode
      fun {EncodeProc IL _}
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
	 M =
	 case IL
	 of elem(tag: 'card.wild'
		 arg: WildA ...) then
	    M =
	    case WildA
	    of '!' then OneM
	    [] '?' then OptM
	    [] '*' then AnyM
	    [] '+' then GtOneM
	    else
	       raise error1('functor':'Compiler/Lattices/Card.ozf' 'proc':'EncodeProc' msg:'Illformed wild card in IL expression, expected !, ?, * or +, but got: '#WildA info:o(IL) coord:Coord file:File) end
	    end
	 in
	    M
	 [] elem(tag: 'card.set'
		 args: IILs ...) then
	    Is = {Map IILs Helpers.iIL2I}
	    M = {FS.value.make Is}
	 in
	    M
	 [] elem(tag: 'card.interval'
		 arg1: IIL1
		 arg2: IIL2 ...) then
	    I1 = {Helpers.iIL2I IIL1}
	    I2 = {Helpers.iIL2I IIL2}
	    M = {FS.value.make I1#I2}
	 in
	    M
	 else
	    raise error1('functor':'Compiler/Lattices/Card.ozf' 'proc':'EncodeProc' msg:'Illformed IL cardinality.' info:o(IL) coord:Coord file:File) end
	 end
      in
	 [M]
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {MSpec2IL MSpec}
	 case MSpec
	 of !NoneMSpec then
	    elem(tag: 'card.set'
		 args: nil)
	 [] !OneMSpec then
	    elem(tag: 'card.wild'
		 arg: '!')
	 [] !OptMSpec then
	    elem(tag: 'card.wild'
		 arg: '?')
	 [] !AnyMSpec then
	    elem(tag: 'card.wild'
		 arg: '*')
	 [] !GtOneMSpec then
	    elem(tag: 'card.wild'
		 arg: '+')
	 [] [I1#I2] then
	    IIL1 = {Helpers.i2IIL I1}
	    IIL2 = {Helpers.i2IIL I2}
	 in
	    elem(tag: 'card.interval'
		 arg1: IIL1
		 arg2: IIL2)		   
	 elseif {IsList MSpec} then
	    IILs = {Helpers.expandMSpec MSpec Helpers.i2IIL}
	 in
	    elem(tag: 'card.set'
		 args: IILs)
	 else
	    raise error1('functor':'Compiler/Lattices/Card.ozf' 'proc':'MSpec2IL' msg:'Cannot convert finite set specification into an IL cardinality.' info:o(MSpec) coord:noCoord file:noFile) end
	 end
      end
      %%
      fun {DecodeDetProc M}
	 MSpec1 = {FS.reflect.lowerBound M}
	 IL1 = {MSpec2IL MSpec1}
	 MSpec2 = {FS.reflect.upperBound M}
	 IL2 = {MSpec2IL MSpec2}
	 IL =
	 if IL1==IL2 then
	    IL1
	 else
	    elem(tag: '_'
		 args: [IL1 IL2])
	 end
      in
	 IL
      end
      DecodeNonDetProc = DecodeDetProc
      fun {Decode M}
	 {Helpers.decode M DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {MSpec2OL MSpec}
	 case MSpec
	 of !NoneMSpec then top
	 [] !OneMSpec then '!'
	 [] !OptMSpec then '?'
	 [] !AnyMSpec then '*'
	 [] !GtOneMSpec then '+'
	 [] nil then top
	 [] [I1#I2] then
	    I11 = if I1==FD.sup then infty else I1 end
	    I21 = if I2==FD.sup then infty else I2 end
	 in
	    [I11#I21]
	 elseif {IsList MSpec} then
	    MSpec1 = {Map MSpec
		      fun {$ I}
			 I1 = if I==FD.sup then infty else I end
		      in
			 I1
		      end}
	 in
	    MSpec1
	 else
	    raise error1('functor':'Compiler/Lattices/Card.ozf' 'proc':'MSpec2OL' msg:'Cannot convert finite set specification into an OL cardinality.' info:o(MSpec) coord:noCoord file:noFile) end
	 end
      end
      fun {PrettyDetProc M AbbrB}
	 MSpec1 = {FS.reflect.lowerBound M}
	 OL1 = {MSpec2OL MSpec1}
	 MSpec2 = {FS.reflect.upperBound M}
	 OL2 = {MSpec2OL MSpec2}
	 OL =
	 if OL1==OL2 then
	    OL1
	 else
	    '_'(OL1 OL2)
	 end
      in
	 OL
      end
      PrettyNonDetProc = PrettyDetProc
      fun {Pretty M AbbrB}
	 {Helpers.pretty M PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      end
      %% count
      fun {Count}
	 o(fd: 0
	   fs: 1)
      end
      %% build lattice
      Lat =
      elem(tag: card
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
