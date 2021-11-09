%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Helpers(cIL2A) at 'Helpers.ozf'
export
   Open
   Close
define
   %% Open: DIDA I OutputRec -> U
   %% Prints nodes in the intermediate language for dimension DIDA,
   %% solution I, and output record OutputRec.
   proc {Open DIDA I OutputRec}
      NodeILs = OutputRec.nodeILs
      NodeILs1 = {Map NodeILs
		  fun {$ IL}
		     ILs = IL.args
		     ILs1 =
		     {Filter ILs
		      fun {$ CIL#_}
			 A = {Helpers.cIL2A CIL}
		      in
			 A==DIDA orelse
			 A==entryIndex orelse
			 A==index orelse
			 A==word
		      end}
		  in
		     o(tag: record
		       args: ILs1)
		  end}
      PrintProc = OutputRec.printProc
   in
      {PrintProc I#NodeILs1}
   end
   %% Close: DIDA -> U
   %% Does nothing.
   proc {Close _}
      skip
   end
end
