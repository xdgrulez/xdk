%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%

%%
%%  Module ListUtils
%%
%%  Exports common list procedures.
%%
functor
export
   MapTail
   TakeTail
   SubtractNth
   PushIfUnique
   Union
prepare
   Drop = List.drop
define
   %%
   %% MapTail: Xs -> T -> F -> Ys - similar to the usual Map predicate
   %% but forthe fact that the resulting list - Ys - will have T as tail.
   fun {MapTail Xs T F}
      case Xs of nil then T
      [] Y|Ys then {F Y}|{MapTail Ys T F}
      end
   end
   %%
   %% TakeTail: Xs -> I -> OrigT -> T -> Ys - similar to the usual List.take
   %% predicate but for the fact that the resulting list - Ys - will have
   %% T as tail and the not taken rest of Xs is returned in OrigT.
   fun {TakeTail Xs I OrigT T}
      if I < 1 orelse Xs == nil then
	 OrigT = Xs
	 T
      elsecase Xs of 
	 X|Ys then X|{TakeTail Ys I-1 OrigT T}
      end
   end
   %%
   %% SubtractNth: Xs -> N -> Ys - takes out the Nth element from Xs.
   proc {SubtractNth Xs N Ys} NotTaken YsRest in
      Ys = {TakeTail Xs N-1 NotTaken YsRest}
      YsRest = {Drop NotTaken 1}
   end
   %%
   %% PushIfUnique: Xs -> X -> Ys - pushes X into Xs if it is not a member.
   fun {PushIfUnique Xs X}
      if {Member X Xs} then Xs else X|Xs end
   end
   %%
   %% Union: Xs -> Ys -> Zs - pushes all elements of Xs into Ys
   %% that are not already there.
   fun {Union Xs Ys} {FoldL Xs PushIfUnique Ys} end

end