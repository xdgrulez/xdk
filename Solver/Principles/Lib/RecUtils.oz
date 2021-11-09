%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
export
   NewFactory
   MkF2I
   NumberFields
prepare
   RForAll = Record.forAll
   RFoldL = Record.foldL
   RClone = Record.clone
define
   local
      fun {MkUnit} unit end
   in
      fun {NewFactory L LIs}
	 Matrix = {MakeRecord L LIs}
      in
	 {RForAll Matrix MkUnit}
	 fun {$} {RClone Matrix} end
      end
   end

   local
      fun {AddAndSet Acc V}
	 V = Acc
	 Acc+1
      end
   in
      proc {NumberFields Rec} {RFoldL Rec AddAndSet 1 _} end
   end
   
   fun {MkF2I Rec}
      {NumberFields Rec}
      fun {$ F} Rec.F end
   end
end