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

functor
import
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      %% Auxiliary function to make C the codomain of mapping R
      proc {Codomain C R}
	 {Record.forAll R proc {$ S} {FS.subset S C} end}
      end
      
      %% D is a FD control variable.  If D=1, constrain S3 to S1.
      %% Otherwise, constrain S3 to S2.
      proc {Conditional D S1 S2 S3}
	 D2 = {FD.int 1#2}
      in
	 {FD.sum [D 1] '=:' D2}
	 {Select.fs unit(S2 S1) D2 S3}
      end
      %%
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      if {Helpers.checkModel 'OrderWithCutsMakeNodes.oz' Nodes
	  [DIDA#eqdown DIDA#labels]} then
	 DIDA2LabelLat = G.dIDA2LabelLat
	 LabelLat = {DIDA2LabelLat DIDA}
	 NodeSet = Nodes.1.nodeSet
	 Models = {List.map Nodes fun {$ N} N.DIDA.model end}

	 %% delegated material for all nodes, sorted by label
	 Delegated =
	 {Record.mapInd {Record.make unit LabelLat.constants}
	  fun {$ L _} {List.map Models fun {$ N} N.giveProjL.L end} end}
      in
	 for Node in Nodes do
	    Model = Node.DIDA.model

	    %% get arguments
	    OnLabels = {ArgRecProc 'On' o('_': Node)}
	    CutSpec = {ArgRecProc 'Cut' o('_': Node)}
	    PasteLabels = {ArgRecProc 'Paste' o('_': Node)}

	    %% initialise variables
	    {Codomain NodeSet Model.selfSet}
	    {FS.subset Model.yield NodeSet}
	    {FS.subset Model.yieldS NodeSet}
	    {Codomain NodeSet Model.yieldL}
	    {Codomain NodeSet Model.pasteByL}
	    {FS.subset Model.paste NodeSet}
	    {Codomain NodeSet Model.pasteL}
	    {Codomain NodeSet Model.takeProjL}
	    {Codomain NodeSet Model.giveProjL}
	    {Codomain NodeSet Model.keepProjL}

	    %% cut in labels -> labels^2
	    %% restricts cutSpec to the labels actually realised
	    %% by the current lexical entry
	    Cut =
	    {Record.mapInd CutSpec
	     fun {$ L S}
		{Conditional
		 {FS.reified.equal Model.daughtersL.L FS.value.empty}
		 FS.value.empty S}
	     end}
	    CutDomain = {FS.unionN Cut}
	    
	    %% list of pastes for this node
	    PasteByL =
	    {List.map LabelLat.constants
	     fun {$ L} Model.pasteByL.L end}

	    %% list of takes for this node
	    TakeProjL =
	    {List.map LabelLat.constants
	     fun {$ L} Model.takeProjL.L end}
	 in
	    %% self(w) in on(w)
	    {FS.include Model.'self' OnLabels}
	    
	    %% pos(w) = uplus{self_s(w) | s in selfs}
	    {FS.partition Model.selfSet Node.pos}
	    
	    %% |self_l(w)| = 1 iff self(w) == l
	    for L in LabelLat.constants do
	       I = {LabelLat.aI2I L}
	    in
	       {FD.equi
		{FD.reified.equal {FS.card Model.selfSet.L} 1}
		{FD.reified.equal Model.'self' I} 1}
	    end
	    
	    %% yield(w) = pos(w) union yieldS(w)
	    Model.yield = {FS.union Node.pos Model.yieldS}
	    
	    %% |yield(w)| = |eqdown(w)|
	    {FD.equal
	     {FS.card Model.yield}
	     {FS.card Model.eqdown}}

	    for L in LabelLat.constants do
	       LI = {LabelLat.aI2I L}
	       
	       %% proj(w)(l) = yield(w)(l) union selfSet(w)(l)
	       ProjL = {FS.union Model.yieldL.L Model.selfSet.L}
	    in
	       %% material delegated from mother by label l:
	       %% pasteByL(w)(l) =
	       %% union {giveProj(l)(v) | v in mothersL(w)(l)}
	       Model.pasteByL.L =
	       {Select.union Delegated.L Model.mothersL.L}

	       %% material pasted into site l:
	       %% pasteL(w)(l) =
	       %% paste(w), if l in pasteLabels, empty set otherwise
	       Model.pasteL.L =
	       {Conditional {FS.reified.include LI PasteLabels}
		Model.paste FS.value.empty}
	       
	       %% takeProj(w)(l) =
	       %% proj(w)(l) union union paste(w)(l)
	       Model.takeProjL.L =
	       {FS.union ProjL Model.pasteL.L}

	       %% giveProj(w)(l) =
	       %% union {takeProj(w)(l2) | l2 in cutDomain(w)(l)}
	       Model.giveProjL.L =
	       {Select.union TakeProjL Cut.L}

	       %% keepProj(w)(l) =
	       %% takeProjL(w)(l) union giveProj(w)(l) -
	       %% union {giveProj(w)(l2) | l2 in labels, l2 != l}
	       Model.keepProjL.L =
	       {Conditional {FS.reified.include LI CutDomain}
		FS.value.empty
		{FS.union Model.takeProjL.L Model.giveProjL.L}}
	    end
	    
	    %% paste(w) = union {pasteByL(w)(l) | l in labels(w)}
	    Model.paste = {Select.union PasteByL Model.labels}
	 end
      end
   end
end
