%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
%   System(show)
   
   Helpers(posSort) at 'Helpers.ozf'
export
   Generate
prepare
   ListMapInd = List.mapInd
   ListTake = List.take
define
   V2S = VirtualString.toString
   S2A = String.toAtom
   %% Generate: Nodess -> Rec
   %% Using the list of solutions Nodess, creates a record Rec including the fields:
   %%   'number of orderings': <number of differing orderings>
   %%   'number of solutions': <number of solutions>
   %%   'ordering -> solutions': <record mapping orderings to lists of indices
   %%                             corresponding to their solutions>
   fun {Generate Nodess}
      %% create tuples A#I where A is an ordering and I the index of
      %% its corresponding solution
      AITups =
      {ListMapInd Nodess
       fun {$ I Nodes}
	  Nodes1 = {Sort Nodes
		    fun {$ Node1 Node2}
		       {Helpers.posSort Node1 Node2}
		    end}
	  WordAs = {Map Nodes1 fun {$ Node1} Node1.word end}
	  WordV = {FoldL WordAs
		   fun {$ AccV A}
		      if A=='' then
			 AccV
		      else
			 (AccV#A#' ')
		      end
		   end ''}
	  WordS = {V2S WordV}
	  WordS1 = {ListTake WordS {Length WordS}-1}
	  WordA = {S2A WordS1}
       in
	  WordA#I
       end}
      %% create mapping AIsRec, where A is an ordering and Is are the
      %% indices of its corresponding solutions
      AIsDict = {NewDictionary}
      for A#I in AITups do
	 Is = {CondSelect AIsDict A nil}
      in
	 AIsDict.A := I|Is
      end
      AIsRec = {Dictionary.toRecord o AIsDict}
      %%
      OrderingsI = {Width AIsRec}
      %%
      SolutionsI = {Length Nodess}
   in
      o('number of orderings': OrderingsI
	'number of solutions': SolutionsI
	'ordering -> solutions': AIsRec)
   end
end
