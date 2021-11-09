functor
import
   Clls(check toVars) at 'x-ozlib://chorus/clls/clls.ozf'
   Dictionary(new) at 'x-ozlib://base/dictionary.ozf'
export 
   make:MakeGraph        
   
   %% type options= unit(
   %%                  title: Title
   %%                  complete:Bool 
   %%                          % whether the wole constraints is
   %%                  ...     % drawn or the part below top only
   %%                  nodeRelations: Bool
   %%                  reint:  
   %%                  beta:   
   %%                   )
   %% subtype opts options    % all features in opts are optional   

define

   fun {MakeGraph Literals MakeMenuEntries}


      %%
      %% collectors for edges and node labels 
      %%

      LabelDict = {Dictionary.new}   %% yields Var -> Label
      EdgesDict = {Dictionary.new}   %% yields Var -> Edges

      proc {AddEdge Var1 Var2 Kind}
	 Edge = case Kind
		of dom then 
		   edge(kind:dom to:Var2 m:nil)
		else %% nondominance edges don't have menues
		   edge(kind:Kind to:Var2 m:nil)
		end
      in
	 {EdgesDict.collect Var1 Edge}
      end
      
      AddLabel = LabelDict.put

      %%
      %% edge creators for all kinds of literals %%%%%%%%%%%%%
      %%

      proc {CreateLamEdge Var1 Var2}
	 {AddEdge Var2 Var1 lam}
      end
      proc {CreateLamInvEdge Var1 Var2}
	 {AddEdge Var1 Var2 lamInv}
      end
      proc {CreateStrictDomEdge Var1 Var2}
	 {AddEdge Var1 Var2 strictDom}
      end
      proc {CreateDomEdge Var1 Var2}
	 {AddEdge Var1 Var2  dom}
      end
      proc {CreateEqualEdge Var1 Var2}
	 {AddEdge Var1 Var2 equal}
      end
      proc {CreateDisjointEdge Var1 Var2}
	 {AddEdge Var1 Var2 disjoint}
      end
      proc {CreateImmDomEdge Var1 Var2}
	 {AddEdge Var1 Var2 default}
      end
      proc {CreateParalEdges Root1 Holes1 Root2 Holes2}
	 for Hole in Holes1 do {AddEdge Root1 Hole para} end
	 for Hole in Holes2 do {AddEdge Root2 Hole para} end
      end
      proc {CreateAnaEdge Var1 Var2}
	 {AddEdge Var2 Var1 ana}
      end
      proc {CreateLabel N Ns}
	 {AddLabel N {Label Ns}}
	 {Record.forAll Ns proc {$ Ni} {CreateImmDomEdge N Ni} end}
      end
      proc {CreateLamInv A Bs}
	 for B in Bs do {CreateLamInvEdge A B} end
      end
      proc {CreateGP gp(Parals)}
	 for P in Parals do
	    p(s(LeftRoot LeftExs) s(RightRoot RightExs)) = P
	 in
	    {CreateParalEdges LeftRoot LeftExs RightRoot RightExs}
	 end
      end
      proc {CreateBeta beta(context:C args:As body:B)}
	 for S in C|B|As do
	    p(s(LeftRoot LeftExs) s(RightRoot RightExs)) = S
	 in
	    {CreateParalEdges LeftRoot LeftExs RightRoot RightExs}
	 end
      end
      proc {CreateRels rel(A B Rels)}
	 case Rels of [strictDom] then
	    {CreateStrictDomEdge A B}
	 [] [invStrictDom] then
	    {CreateStrictDomEdge B A} 
	 [] [equal] then
	    {CreateEqualEdge A B} 
	 [] [disjoint] then
	    {CreateDisjointEdge A B}
	 [] _ then
	    skip
	 end
      end
      proc {CreateP S1 S2}
	 s(LeftRoot  LeftExs)  = S1
	 s(RightRoot RightExs) = S2
      in
	 {CreateParalEdges LeftRoot LeftExs RightRoot RightExs}
      end 
      proc {Ignore _ _}
	 skip
      end

      Create = unit(label   :CreateLabel
		    dom     :CreateDomEdge
		    notEqual:Ignore 
		    lam     :CreateLamEdge
		    lamInv  :CreateLamInv
		    ana     :CreateAnaEdge
		    rel     :CreateRels
		    gp      :CreateGP
		    p       :CreateP
		    beta    :CreateBeta)

      %% collect the actual edges and labels  %%%%%%%%%%%%%%%%%

      %{Clls.check Literals}  %% better check CLLS syntax twice

      for Lit in Literals do
	 Kind = {Label Lit}
      in
	 case Lit of Kind(A1 A2)
	 then {Create.Kind A1 A2}
	 else {Create.Kind Lit}
	 end
      end

      %% compute the daVinci graph

      /* NewNodeLabel = Config.parameter.newNodeLabel */

      fun {NewNodeLabel Var Lab}
	 Var # ':' # Lab
      end

      /*
      fun {ToNode Var}
	 Label = {LabelDict.condGet Var '_'}
      in
	 case {MakeMenuEntries Var}
	 of nil then
	    node(id      : Var
		 edges   : {Reverse {EdgesDict.condGet Var nil}} /* HIER */
		 'OBJECT': {NewNodeLabel Var Label}
		)
	 [] MenuEntries then
	    node(id       : Var
		 edges    : {EdgesDict.condGet Var nil}
		 'OBJECT' : {NewNodeLabel Var Label}
		 'COLOR'  : red
		 menu     : MenuEntries)
	 end
      end
      */
      fun {ToNode Var}
	 Label = {LabelDict.condGet Var '_'}
	 Node  = case {MakeMenuEntries Var}
		 of nil then
		    node(id      : Var
			 edges   : {EdgesDict.condGet Var nil} /* HIER */
			 'OBJECT': {NewNodeLabel Var Label}
			)
		 [] MenuEntries then
		    node(id       : Var
			 edges    : {EdgesDict.condGet Var nil}
			 'OBJECT' : {NewNodeLabel Var Label}
			 'COLOR'  : red
			 menu     : MenuEntries)
		 end
      in
	 case Label of '_' then
	    Node
	 [] '@' then
	    Node
	 [] 'var' then
	    Node
	 [] 'lambda' then
	    Node
	 else
	    {Record.adjoinAt Node 'COLOR' yellow}
	 end
      end

      Vars    = {Clls.toVars Literals}     
      DVGraph = {Map Vars ToNode}
      
      Graph   = unit(nodes:DVGraph
		     edges:nil
		     value:Literals)
   in
      Graph
   end
end
