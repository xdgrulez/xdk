declare
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Multigraph visualization
[NewTkDAG] = {Module.link ['Outputs/Lib/Dag/NewTkDAG/NewTkDAG.ozf']}
proc {ShowMultigraph I NodeRecs}
   DIDAs = {Filter {Arity NodeRecs.1}
	    fun {$ LI}
	       {Not {Member LI [index word]}}
	    end}
   %%
   NodeRecs1 = {Map NodeRecs
		fun {$ NodeRec}
		   o(index: NodeRec.index
		     string: o(text: NodeRec.word))
		end}
   %%
   DIDANodes1EdgesTups =
   {Map DIDAs
    fun {$ DIDA}
       LabeledEdges =
       for NodeRec in NodeRecs I1 in 1..{Length NodeRecs} collect:Collect do
	  if {HasFeature NodeRec.DIDA model} andthen
	     {HasFeature NodeRec.DIDA.model daughtersL} then
	     for LA in {Arity NodeRec.DIDA.model.daughtersL} do
		Is = {FS.reflect.lowerBoundList
		      NodeRec.DIDA.model.daughtersL.LA}
	     in
		for I2 in Is do
		   {Collect o(index1: I1
			      index2: I2
			      label: o(text: LA))}
		end
	     end
	  end
       end
       %%
       UnlabeledEdges =
       for NodeRec in NodeRecs I1 in 1..{Length NodeRecs} collect:Collect do
	  if {HasFeature NodeRec.DIDA model} andthen
	     {HasFeature NodeRec.DIDA.model daughters} then
	     Is = {FS.reflect.lowerBoundList
		   NodeRec.DIDA.model.daughters}
	  in
	     for I2 in Is do
		if {All LabeledEdges
		    fun {$ o(index1: I11
			     index2: I21 ...)}
		       {Not I11==I1 andthen I21==I2}
		    end} then
		   {Collect o(index1: I1
			      index2: I2)}
		end
	     end
	  end
       end
    in
       DIDA#NodeRecs1#{Append LabeledEdges UnlabeledEdges}
    end}
   OptRec = o
   TitleV = 'Multigraph ('#I#')'
   ToplevelW = {New Tk.toplevel tkInit(title: TitleV)}
   FrameW = {NewTkDAG.makeFrameTd DIDANodes1EdgesTups ToplevelW OptRec}
in
   {Tk.batch [
	      grid(rowconfigure ToplevelW 0 weight:1)
	      grid(columnconfigure ToplevelW 0 weight:1)
	      grid(FrameW row:0 column:0 sticky:nswe)
	     ]}
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Logical connectives
fun {Quantify A NodeRecs Proc}
   NodeRecsI = {Length NodeRecs}
   NodeSetM = {FS.value.make 1#NodeRecsI}
   %%
   M = {FS.var.decl}
in
   {FS.subset M NodeSetM}
   for NodeRec in NodeRecs do
      {FD.equi
       {FS.reified.include NodeRec.index M}
       {Proc NodeRec} 1}
   end
   case A
   of forAll then ({FS.card M}=:NodeRecsI)
   [] exists then ({FS.card M}>=:1)
   [] existsOne then ({FS.card M}=:1)
   end
end
%%
fun {ForAll NodeRecs Proc}
   {Quantify forAll NodeRecs Proc}
end
%%
fun {Exists NodeRecs Proc}
   {Quantify exists NodeRecs Proc}
end
%%
fun {ExistsOne NodeRecs Proc}
   {Quantify existsOne NodeRecs Proc}
end
%%
fun {Nega D}
   {FD.nega D}
end
%%
fun {Conj D1 D2}
   {FD.conj D1 D2}
end
%%
fun {Disj D1 D2}
   {FD.disj D1 D2}
end
%%
fun {Impl D1 D2}
   {FD.impl D1 D2}
end
%%
fun {Equi D1 D2}
   {FD.equi D1 D2}
end
%%
fun {Equals X1 X2}
   if X1==X2 then 1 else 0 end
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Multigraph connectives
fun {LabeledEdge NodeRec NodeRec1 DIDA LA}
   {FS.reified.include NodeRec1.index NodeRec.DIDA.model.daughtersL.LA}
end
%%
fun {Edge NodeRec NodeRec1 DIDA}
   {FS.reified.include NodeRec1.index NodeRec.DIDA.model.daughters}
end
%%
fun {StrictDominance NodeRec NodeRec1 DIDA}
   {FS.reified.include NodeRec1.index NodeRec.DIDA.model.down}
end
%%
fun {Word NodeRec}
   NodeRec.word
end
%%
fun {NodeAttributes NodeRec DIDA}
   NodeRec.DIDA.attrs
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Principles
proc {NoCycles NodeRecs}
   {ForAll NodeRecs
    fun {$ NodeRec}
       {Nega
	{StrictDominance NodeRec NodeRec d}}
    end 1}
end
%%
proc {ZeroOrOneIncomingEdges NodeRecs}
   {ForAll NodeRecs
    fun {$ NodeRec}
       {Disj
	{ExistsOne NodeRecs
	 fun {$ NodeRec1} {Edge NodeRec1 NodeRec d} end}
	{Nega
	 {Exists NodeRecs
	  fun {$ NodeRec1} {Edge NodeRec1 NodeRec d} end}}}
    end 1}
end
%%
proc {OneRoot NodeRecs}
   {ExistsOne NodeRecs
    fun {$ NodeRec}
       {Nega
	{Exists NodeRecs
	 fun {$ NodeRec1} {Edge NodeRec1 NodeRec d} end}}
    end 1}
end
%%
proc {Valencya NodeRecs}
   {ForAll NodeRecs
    fun {$ NodeRec}
       {Impl
	{Equals {Word NodeRec} a}
	{Conj
	 {Disj
	  {ExistsOne NodeRecs
	   fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d a} end}
	  {Nega
	   {Exists NodeRecs
	    fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d a} end}}}
	 {Conj
	  {Nega
	   {Exists NodeRecs
	    fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d b} end}}
	  {Conj
	   {Disj
	    {ExistsOne NodeRecs
	     fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d a} end}
	    {Nega
	     {Exists NodeRecs
	      fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d a} end}}}
	   {ExistsOne NodeRecs
	    fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d b} end}}}}}
    end 1}
end
%%
proc {Valencyb NodeRecs}
   {ForAll NodeRecs
    fun {$ NodeRec}
       {Impl
	{Equals {Word NodeRec} b}
	{Conj
	 {Nega
	  {Exists NodeRecs
	   fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d a} end}}
	 {Conj
	  {ExistsOne NodeRecs
	   fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d b} end}
	  {Conj
	   {Nega
	    {Exists NodeRecs
	     fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d a} end}}
	   {Nega
	    {Exists NodeRecs
	     fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d b} end}}}}}}
    end 1}
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Oz Script
[Select] = {Module.link ['Solver/Principles/Lib/Select/Select.ozf']}
fun {MakeScript WordAs PrincipleProcs}
   proc {Script NodeRecs}
      NodeRecsI = {Length WordAs}
      NodeSetM = {FS.value.make 1#NodeRecsI}
      !NodeRecs = {List.mapInd WordAs
		   fun {$ I WordA}
		      NodeRec = o(index: _
				  word: _
				  d: o(model: o(daughters: _
						daughtersL: o(a: _
							      b: _)
						down: _)
				       attrs: o))
		   in
		      NodeRec.index = I
		      NodeRec.word = WordA
		      {FS.subset NodeRec.d.model.daughters NodeSetM}
		      {FS.subset NodeRec.d.model.daughtersL.a NodeSetM}
		      {FS.subset NodeRec.d.model.daughtersL.b NodeSetM}
		      {FS.subset NodeRec.d.model.down NodeSetM}
		      NodeRec
		   end}
      %%
      EqDownMs = {Map NodeRecs
		  fun {$ NodeRec}
		     EqM = {FS.value.make NodeRec.index}
		     EqDownM = {FS.union EqM NodeRec.d.model.down}
		  in
		     EqDownM
		  end}
   in
      for NodeRec in NodeRecs do
	 {FS.unionN NodeRec.d.model.daughtersL NodeRec.d.model.daughters}
	 {Select.union EqDownMs NodeRec.d.model.daughters NodeRec.d.model.down}
	 EqM = {FS.value.make NodeRec.index}
      in
	 {FD.impl
	  {FS.reified.equal EqM NodeRec.d.model.daughters}
	  {FS.reified.equal EqM NodeRec.d.model.down} 1}
      end
      %%
      for PrincipleProc in PrincipleProcs do
	 {PrincipleProc NodeRecs}
      end
      %%
      for NodeRec in NodeRecs do
	 {FS.distribute naive
	  [NodeRec.d.model.daughtersL.a NodeRec.d.model.daughtersL.b]}
      end
   end
in
   Script
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Exploration
PrincipleProcs =
[
 NoCycles
 ZeroOrOneIncomingEdges
 OneRoot
 Valencya
 Valencyb
]
Script = {MakeScript [a b a b] PrincipleProcs}
{Explorer.object delete(information all)}
{Explorer.object add(information ShowMultigraph label:'Show multigraph')}
{ExploreAll Script}
