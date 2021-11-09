%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   DictUtils(condPut:CondPut) at 'DictUtils.ozf'
export
   New
   Dict
prepare
   RFoldRInd = Record.foldRInd
   RClone = Record.clone
   ValueDot = Value.'.'
define
   Dict = o(dot:CondPut
	    new:fun {$ _} {NewDictionary} end)
   
   fun {K2I Factors KeyNorm K I Acc}
      if I == 0 then Acc+1 else
	 {K2I Factors KeyNorm K I-1 ({KeyNorm.I K.I}-1)*Factors.I+Acc}
      end
   end

   fun {MkDefaultTuple W} {MakeTuple '#' W} end

   fun {New Dims KeyNorm Base}
      Dot = {CondSelect Base dot ValueDot}
      New = {CondSelect Base new MkDefaultTuple}
      W = {Width Dims}
      Factors = {RClone Dims}
      Card = {RFoldRInd Dims fun {$ DimI Dim Acc}
				Factors.DimI = Acc
				Dim*Acc
			     end 1}
      fun {MyK2I K} {K2I Factors KeyNorm K W 0} end
   in
      o(k2I:MyK2I
	card:Card
	dot:fun {$ M K} {Dot M {MyK2I K}} end
	new:fun {$} {New Card} end
       )
   end
end