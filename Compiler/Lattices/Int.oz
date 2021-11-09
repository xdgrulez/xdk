%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   FD(is reflect sup)

   FD1(int) at '../../Solver/Principles/Lib/FD.ozf'
   
   Select(fd) at '../../Solver/Principles/Lib/Select.ozf'

   Helpers(iIL2I i2IIL encode decode pretty) at 'Helpers.ozf'

   Flat(make) at 'Flat.ozf'
export
   Make
define
   %% Make: U -> Lat
   %% Makes an integer lattice.
   %% SL = D.
   fun {Make}
      SupI = FD.sup
      %%
      FlatLat = {Flat.make}
      %% top
      Top = FlatLat.top
      %% bot
      Bot = FlatLat.bot
      %% glb
      Glb = FlatLat.glb
      %% select
      fun {Select1 Ds D}
	 SL =
	 if {All Ds FD.is} then
	    {Select.fd Ds D}
	 else
	    thread {Nth Ds D} end
	 end
      in
	 SL
      end
      %% makeVar
      fun {MakeVar} {FD1.int 1#SupI} end
      %% encode
      fun {EncodeProc IIL _}
	 I = {Helpers.iIL2I IIL}
      in
	 [I]
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {DecodeDetProc I}
	 if I==Top then elem(tag: top)
	 elseif I==Bot then elem(tag: bot)
	 else
	    IIL = {Helpers.i2IIL I}
	 in
	    IIL
	 end
      end
      fun {DecodeNonDetProc D}
	 DSpec = {FD.reflect.dom D}
	 IL = elem(tag: '_'
		   args: [DSpec])
      in
	 IL
      end
      fun {Decode SL}
	 {Helpers.decode SL DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc I AbbrB} I end
      fun {PrettyNonDetProc D AbbrB}
	 Is = {FD.reflect.domList D}
      in
	 if {Length Is}>50 then
	    DSpec = {FD.reflect.dom D}
	 in
	    '_'(DSpec)
	 else
	    '_'(Is)
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
      elem(tag: int
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
