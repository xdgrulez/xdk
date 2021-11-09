%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(showError)
export
   CheckModel

   Pair2I
   I2Pair

   Sum

   Gorn2A
   A2Gorn
   GornLessThan
   GornDom
   MakeRelation

   X2V
   Xs2X
   
   Str2Xs

   AppendList
   NoDoubles
prepare
   ListDrop = List.drop
   ListIsPrefix = List.isPrefix
   ListToRecord = List.toRecord
define
   V2A = VirtualString.toAtom
   A2S = Atom.toString
   S2I = String.toInt
   %%
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% CheckModel: V Nodes DIDAATups -> B
   %% V is a constraint name. Nodes is the set of node records
   %% describing the current solution.
   %% Returns true if for all pairs DIDA#A in DIDAATups (where DIDA
   %% is a dimension ID and A a field), Node.DIDA.model has field A.
   fun {CheckModel V Nodes DIDAATups}
      Node = Nodes.1
      B =
      for DIDA#A in DIDAATups return:Return default:true do
	 if {Not {HasFeature Node.DIDA.model A}} then
	    {System.showError 'warning: cannot post constraint '#V#' because the nodes lack feature '#A#' on dimension '#DIDA}
	    {Return false}
	 end
      end
   in
      B
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Pair2I: I1#I2 I -> I3
   %% Maps a pair I1#I2 of two integers to a unique integer I3,
   %% where I2 is from a finite domain with cardinality I.
   fun {Pair2I I1#I2 I}
      (I1-1)*I+(I2-1)
   end
   %%
   %% I2Pair: I3 I -> I1#I2
   %% Maps an integer I3 to a pair I1#I2 of two integers,
   %% where I2 is from a finite domain with cardinality I.
   fun {I2Pair I3 I}
      ((I3 div I)+1)#((I3 mod I)+1)
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Sum: Is -> I
   %% Calculates the sum of all Is.
   fun {Sum Is}
      {FoldL Is fun {$ AccI I} AccI+I end 0}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Gorn2A: Gorn -> A
   %% Encodes Gorn address Gorn into atom A, e.g. {Gorn2A [1 2 3]}
   %% returns '123', and {Gorn2A nil} returns '0'.
   fun {Gorn2A Gorn}
      V = if Gorn==nil then
	     0
	  else
	     {FoldL Gorn
	      fun {$ AccV I} AccV#I end ''}
	  end
   in
      {V2A V}
   end
   %% A2Gorn: A -> Gorn
   %% Returns Gorn address Gorn encoded in atom A.
   fun {A2Gorn A}
      S = {A2S A}
      Is = {Map S
	    fun {$ Ch} {S2I [Ch]} end}
   in
      if Is==[0] then nil else Is end
   end
   %% GornLessThan Gorn1 Gorn2 -> B
   %% Does Gorn address Gorn1 precede Gorn address Gorn2?
   fun {GornLessThan Gorn1 Gorn2}
      if Gorn1==nil orelse Gorn2==nil then
	 false
      elseif Gorn1.1==Gorn2.1 then
	 {GornLessThan {ListDrop Gorn1 1} {ListDrop Gorn2 1}}
      else
	 Gorn1.1<Gorn2.1
      end
   end
   %% GornDom Gorn1 Gorn2 -> B
   %% Does Gorn address Gorn1 dominate Gorn address Gorn2?
   fun {GornDom Gorn1 Gorn2}
      {ListIsPrefix Gorn1 Gorn2} andthen {Not Gorn1==Gorn2}
   end
   %% MakeRelationRec: LabelLat RelationA FS1 -> LALMRec
   %%
   %% Makes a record mapping label atoms LA to sets of labels LM,
   %% encoding the relation RelationA, assuming that the labels in
   %% label lattice LabelLat are Gorn addresses.
   %%
   %% RelationA can either be:
   %% * dom: LALMRec.LA is the set of Gorn addresses dominated by LA
   %% * prec: LALMRec.LA is the set of Gorn addresses preceded by LA
   %% * dom1: LALMRec.LA is the set of Gorn addresses dominating LA
   %% * prec1: LALMRec.LA is the set of Gorn addresses preceding LA
   fun {MakeRelation LabelLat RelationA FS1}
      LAs = LabelLat.constants
      A2I = LabelLat.aI2I
      LALMTups =
      {Map LAs
       fun {$ LA}
	  Gorn = {A2Gorn LA}
	  LA1s =
	  for LA1 in LAs collect:Collect do
	     Gorn1 = {A2Gorn LA1}
	     RelationB = case RelationA
			 of dom then {GornDom Gorn Gorn1}
			 [] prec then {GornLessThan Gorn Gorn1}
			 [] dom1 then {GornDom Gorn1 Gorn}
			 [] prec1 then {GornLessThan Gorn1 Gorn}
			 end
	  in
	     if RelationB then {Collect LA1} end
	  end
	  LI1s = {Map LA1s
		  fun {$ LA1} {A2I LA1} end}
	  LM1 = {FS1.value.make LI1s}
       in
	  LA#LM1
       end}
      LALMRec = {ListToRecord o LALMTups}
   in
      LALMRec
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% X2V: X -> V
   %% Transforms value X into a virtual string V.
   fun {X2V X}
      V = {Value.toVirtualString X 10000 10000}
   in
      V
   end
   %% Xs2X: Xs SepA -> X
   %% Folds Xs into X.
   %% SepA is the separator (usually '\n' or ' ').
   fun {Xs2X Xs SepA}
      if Xs==nil then ''
      else
	 X1|Xs1 = Xs
	 X =
	 {FoldL Xs1
	  fun {$ AccX X} AccX#SepA#X end X1}
      in
	 X
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% Str2Xs: Str -> Xs
   %% Get the list of elements Xs from the stream Str.
   fun {Str2Xs Str}
      fun {Str2Xs1 Str AccXs}
%	 {Show Str}
	 if {IsFuture Str} then
	    AccXs
	 elsecase Str of X|Xs then
	    {Str2Xs1 Xs X|AccXs}
	 end
      end
      %%
      Xs = {Str2Xs1 Str nil}
   in
      {Reverse Xs}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AppendList: Xss -> Xs
   %% Appends lists Xss in order to yield list Xs.
   fun {AppendList Xss}
      {FoldL Xss
       fun {$ AccXs Xs} {Append AccXs Xs} end nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% NoDoubles: Xs -> Ys
   %% Removes double elements from list Xs.
   fun {NoDoubles Xs}
      {FoldL Xs fun {$ AccXs X}
		   if {Member X AccXs} then
		      AccXs
		   else
		      {Append AccXs [X]}
		   end
		end nil}
   end
end
