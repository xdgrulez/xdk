%%
%% Authors:
%%   Ralph Debusmann <rade@ps.uni-sb.de>
%%   Denys Duchier <duchier@ps.uni-sb.de>
%%   Marco Kuhlmann <kuhlmann@ps.uni-sb.de>
%%
%% Copyright:
%%   Ralph Debusmann, 2001-2011
%%   Denys Duchier, 2001-2011
%%   Marco Kuhlmann, 2003-2011
%%

%% * The yield of an initial node is convex.
%%
%% * The extended yield is the yield plus the paste

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%
%% (2) The extended yield of an auxiliary node is convex.  The
%% extended yield is the yield plus whatever gets pasted into the
%% node.
%%
%% 

functor
import
   %% TODO: import only needed methods
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      if {Helpers.checkModel 'OrderWithCutsConditions.oz' Nodes
	  [DIDA#daughters
	   DIDA#daughtersL]} then
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 %%
	 Models = {List.map Nodes fun {$ N} N.DIDA.model end}
	 %%
	 Yields = {List.map Models fun {$ N} N.yield end}
      in
	 for Node in Nodes do
	    Model = Node.DIDA.model
	    %%
	    OrderedLabelsI = {ArgRecProc 'Order' o('_': Node)}
	    OrderedLabelsA = {List.map OrderedLabelsI LabelLat.i2AI}

	    DerivedYield = {FS.partition [Model.yield Model.paste]}
	    
	    %% ordered list of daughters (incl self-daughter)
	    OrderedDaughters =
	    {List.map OrderedLabelsA
	     fun {$ L}
		{FS.unionN
		 [Model.daughtersL.L
		  Model.selfSet.L
		  Model.pasteL.L]}
	     end}

	    %% ordered list of derived projections
	    OrderedDerivedProjections =
	    {List.map OrderedLabelsA
	     fun {$ L} Model.keepProjL.L end}
	 in
	    %% yieldS(w) = union{yield(w') | w' in daughters(w)}
	    Model.yieldS = {Select.union Yields Model.daughters}

	    for L in LabelLat.constants do
	       %% yield_l(w) = union{yield(w') | w' in daughters_l(w)}
	       Model.yieldL.L = {Select.union Yields Model.daughtersL.L}
	       %% |daughters_l(w)| =< |yield_l(w)|
	       {FD.lesseq
		{FS.card Model.daughtersL.L}
		{FS.card Model.yieldL.L}}
	    end
	    
	    %% yieldS(w) = uplus{yield_l(w) | l in labels}
	    {FS.partition Model.yieldL Model.yieldS}

%%%%%%

	    {FS.int.seq OrderedDaughters}
	    {Select.seqUnion OrderedDerivedProjections DerivedYield}
%	    {FS.int.convex {FS.partition [Model.yield Model.paste]}}
%	    {Select.seqUnion
%	     {List.map OrderedLabelsA fun {$ L} Model.derivedProjL.L end}
%	     {FS.union Model.yield Model.paste}}
	 end
      end
   end
end
