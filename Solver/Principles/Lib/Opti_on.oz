%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(onToplevel)
   FS(value)

   NatUtils(nonMonIsIn) at 'NatUtils.so{native}'
export
   IsIn
define
   %% IsIn: I M -> X
   %% Checks whether I is an element of in M. Returns 'in' if I is in
   %% M, 'out' if I is not in M, and 'unknown' if it cannot yet be
   %% determined whether I is in M or not.
   fun {IsIn I M}
      if {System.onToplevel} then
	 'unknown'
      else
	 if {IsDet M} andthen M==FS.value.empty then
	    'out'
	 else
	    {NatUtils.nonMonIsIn I M}
	 end
      end
   end
end
