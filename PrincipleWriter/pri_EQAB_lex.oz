declare
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Multigraph visualization
[NewTkDAG] = {Module.link ['../Outputs/Lib/Dag/NewTkDAG/NewTkDAG.ozf']}
proc {ShowMultigraph I NodeRecs}
   DIDAs = {Filter {Arity NodeRecs.1}
	    fun {$ LI}
	       {Not {Member LI [index word entryIndex]}}
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
fun {QuantifyDom A DomLat Proc}
   CardI = DomLat.card
   DomSetM = {FS.value.make 1#CardI}
   %%
   M = {FS.var.decl}
in
   {FS.subset M DomSetM}
   for A in DomLat.constants do
      I = {DomLat.aI2I A}
   in
      {FD.equi
       {FS.reified.include I M}
       {Proc A I} 1}
   end
   case A
   of forAll then ({FS.card M}=:CardI)
   [] exists then ({FS.card M}>=:1)
   [] existsOne then ({FS.card M}=:1)
   end
end
%%
fun {ForAllDom DomLat Proc}
   {QuantifyDom forAll DomLat Proc}
end
%%
fun {ExistsDom DomLat Proc}
   {QuantifyDom exists DomLat Proc}
end
%%
fun {ExistsOneDom DomLat Proc}
   {QuantifyDom existsOne DomLat Proc}
end
%%
fun {QuantifyNodes A NodeRecs Proc}
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
fun {ForAllNodes NodeRecs Proc}
   {QuantifyNodes forAll NodeRecs Proc}
end
%%
fun {ExistsNodes NodeRecs Proc}
   {QuantifyNodes exists NodeRecs Proc}
end
%%
fun {ExistsOneNodes NodeRecs Proc}
   {QuantifyNodes existsOne NodeRecs Proc}
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
fun {EqualsWord X1 X2}
   if X1==X2 then 1 else 0 end
end
%%
fun {EqualsFD D1 D2}
   D1=:D2
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
fun {Attrs NodeRec DIDA}
   NodeRec.DIDA.attrs
end
%%
fun {Entry NodeRec DIDA}
   NodeRec.DIDA.entry
end
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Principles
proc {NoCycles NodeRecs}
   {ForAllNodes NodeRecs
    fun {$ NodeRec}
       {Nega
	{StrictDominance NodeRec NodeRec d}}
    end 1}
end
%%
proc {ZeroOrOneIncomingEdges NodeRecs}
   {ForAllNodes NodeRecs
    fun {$ NodeRec}
       {Disj
	{ExistsOneNodes NodeRecs
	 fun {$ NodeRec1} {Edge NodeRec1 NodeRec d} end}
	{Nega
	 {ExistsNodes NodeRecs
	  fun {$ NodeRec1} {Edge NodeRec1 NodeRec d} end}}}
    end 1}
end
%%
proc {OneRoot NodeRecs}
   {ExistsOneNodes NodeRecs fun {$ V} {Nega {ExistsNodes NodeRecs fun {$ V2} {Edge V2 V d} end} } end 1} end
% proc {OneRoot NodeRecs}
%    {ExistsOneNodes NodeRecs
%     fun {$ NodeRec}
%        {Nega
% 	{ExistsNodes NodeRecs
% 	 fun {$ NodeRec1} {Edge NodeRec1 NodeRec d} end}}
%     end 1}
% end
%%
proc {In NodeRecs}
   {ForAllNodes NodeRecs
    fun {$ NodeRec}
       {ForAllDom LabelLat
	fun {$ LabelA LabelI}
	   {Conj
	    {Impl
	     {EqualsFD
	      {Entry NodeRec d}.'in'.LabelA {CardLat.aI2I '0'}}
	     {Nega
	      {ExistsNodes NodeRecs
	       fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d LabelA} end}}}
	    {Conj
	     {Impl
	      {EqualsFD
	       {Entry NodeRec d}.'in'.LabelA {CardLat.aI2I '!'}}
	      {ExistsOneNodes NodeRecs
	       fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d LabelA} end}}
	     {Impl
	      {EqualsFD
	       {Entry NodeRec d}.'in'.LabelA {CardLat.aI2I '?'}}
	      {Disj
	       {Nega
		{ExistsNodes NodeRecs
		 fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d LabelA} end}}
	       {ExistsOneNodes NodeRecs
		fun {$ NodeRec1} {LabeledEdge NodeRec1 NodeRec d LabelA} end}}}}}
	end}
    end 1}
end
%%
proc {Out NodeRecs}
   {ForAllNodes NodeRecs
    fun {$ NodeRec}
       {ForAllDom LabelLat
	fun {$ LabelA LabelI}
	   {Conj
	    {Impl
	     {EqualsFD
	      {Entry NodeRec d}.out.LabelA {CardLat.aI2I '0'}}
	     {Nega
	      {ExistsNodes NodeRecs
	       fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d LabelA} end}}}
	    {Conj
	     {Impl
	      {EqualsFD
	       {Entry NodeRec d}.out.LabelA {CardLat.aI2I '!'}}
	      {ExistsOneNodes NodeRecs
	       fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d LabelA} end}}
	     {Impl
	      {EqualsFD
	       {Entry NodeRec d}.out.LabelA {CardLat.aI2I '?'}}
	      {Disj
	       {Nega
		{ExistsNodes NodeRecs
		 fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d LabelA} end}}
	       {ExistsOneNodes NodeRecs
		fun {$ NodeRec1} {LabeledEdge NodeRec NodeRec1 d LabelA} end}}}}}
	end}
    end 1}
end
%%
%% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%% Oz Script
[Select] = {Module.link ['../Solver/Principles/Lib/Select/Select.ozf']}
%%
[Domain] = {Module.link ['../Compiler/Lattices/Domain.ozf']}
%%
LabelAs = [a b]
LabelLat = {Domain.make LabelAs}
%%
CardAs = ['!' '?' '*' '0']
CardLat = {Domain.make CardAs}
Lexicon =
o('a': [o(d: o('in': o(a: {CardLat.aI2I '?'}
		       b: {CardLat.aI2I '0'})
	       out: o(a: {CardLat.aI2I '?'}
		      b: {CardLat.aI2I '!'})))]
  'b': [o(d: o('in': o(a: {CardLat.aI2I '0'}
		       b: {CardLat.aI2I '!'})
	       out: o(a: {CardLat.aI2I '0'}
		      b: {CardLat.aI2I '0'})))])
%%
fun {MakeScript WordAs PrincipleProcs}
   proc {Script NodeRecs}
      NodeRecsI = {Length WordAs}
      NodeSetM = {FS.value.make 1#NodeRecsI}
      !NodeRecs = {List.mapInd WordAs
		   fun {$ I WordA}
		      NodeRec = o(index: _
				  word: _
				  entryIndex: _
				  d: o(model: o(daughters: _
						daughtersL: o(a: _
							      b: _)
						down: _)
				       entry: o('in': o(a: _
							b: _)
						out: o(a: _
						       b: _))
				       attrs: o))
		   in
		      NodeRec.index = I
		      NodeRec.word = WordA
		      %%
		      {FS.subset NodeRec.d.model.daughters NodeSetM}
		      {FS.subset NodeRec.d.model.daughtersL.a NodeSetM}
		      {FS.subset NodeRec.d.model.daughtersL.b NodeSetM}
		      {FS.subset NodeRec.d.model.down NodeSetM}
		      %%
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
      for NodeRec in NodeRecs do
	 Entries = Lexicon.(NodeRec.word)
	 EntryIndexD = {FD.int 1#{Length Entries}}
      in
	 NodeRec.entryIndex = EntryIndexD
	 %%
	 NodeRec.d.entry.'in'.a =
	 {Select.fd {Map Entries fun {$ Entry} Entry.d.'in'.a end} EntryIndexD}
	 NodeRec.d.entry.'in'.b =
	 {Select.fd {Map Entries fun {$ Entry} Entry.d.'in'.b end} EntryIndexD}
	 NodeRec.d.entry.out.a =
	 {Select.fd {Map Entries fun {$ Entry} Entry.d.out.a end} EntryIndexD}
	 NodeRec.d.entry.out.b =
	 {Select.fd {Map Entries fun {$ Entry} Entry.d.out.b end} EntryIndexD}
      end
      %%
      for PrincipleProc in PrincipleProcs do
	 {PrincipleProc NodeRecs}
      end
      %%
      for NodeRec in NodeRecs do
	 {FS.distribute naive
	  [NodeRec.d.model.daughtersL.a NodeRec.d.model.daughtersL.b]}
	 {FD.distribute ff
	  [NodeRec.entryIndex]}
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
 In
 Out
]
%Script = {MakeScript [a b a b a b] PrincipleProcs}
Script = {MakeScript [a b] PrincipleProcs}
{Explorer.object delete(information all)}
{Explorer.object add(information ShowMultigraph label:'Show multigraph')}
{ExploreAll Script}
