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
   
   Helpers(encode decode pretty multiply) at 'Helpers.ozf'

   Flat(make) at 'Flat.ozf'
export
   Make
define
   %% Make: Lat -> Lat
   %% Makes a list lattice with domain Lat.
   %% SL = SLs
   fun {Make DomainLat}
      FlatLat = {Flat.make}
      %% top
      Top = FlatLat.top
      %% bot
      Bot = FlatLat.bot
      %% glb
      Glb = FlatLat.glb
      %% select
      Select = FlatLat.select
      %% makeVar
      MakeVar = FlatLat.makeVar
      %% encode
      fun {EncodeProc IL Extra}
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
	 SLs =
	 case IL
	 of elem(tag: list
		 args: ILs ...) then
	    SLss = {Map ILs
		    fun {$ IL}
		       SLs = {DomainLat.encode IL Extra}
		    in
		       SLs
		    end}
	    SLss1 = {Helpers.multiply SLss}
	 in
	    SLss1
	 else
	    raise error1('functor':'Compiler/Lattices/List.ozf' 'proc':'EncodeProc' msg:'Illformed IL expression' info:o(IL) coord:Coord file:File) end
	 end
      in
	 SLs
      end
      fun {Encode IL Extra} {Helpers.encode IL Lat Extra} end
      %% decode
      fun {DecodeDetProc SLs}
	 if SLs==Top then elem(tag: top)
	 elseif SLs==Bot then elem(tag: bot)
	 else
	    ILs = {Map SLs DomainLat.decode}
	 in
	    elem(tag: list
		 args: ILs)
	 end
      end
      fun {DecodeNonDetProc SLs}
	 elem(tag: '_'
	      args: nil)
      end
      fun {Decode SLs}
	 {Helpers.decode SLs DecodeDetProc DecodeNonDetProc}
      end
      %% pretty
      fun {PrettyDetProc SLs AbbrB}
	 {Map SLs
	  fun {$ SL} {DomainLat.pretty SL AbbrB} end}
      end
      fun {PrettyNonDetProc _ AbbrB} '_' end
      fun {Pretty SL AbbrB}
	 {Helpers.pretty SL PrettyDetProc PrettyNonDetProc Top Bot AbbrB}
      end
      %% count
      Count = FlatLat.count
      %% build lattice
      Lat =
      elem(tag: list
	   top: Top
	   bot: Bot
	   glb: Glb
	   select: Select
	   makeVar: MakeVar
	   encode: Encode
	   decode: Decode
	   pretty: Pretty
	   count: Count
	   %%
	   domain: DomainLat
	   %%
	   encodeProc: EncodeProc)
   in
      Lat
   end
end
