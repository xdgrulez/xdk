%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Tk(toplevel batch)

   Helpers(spec2Is unPickleRec) at 'Helpers.ozf'

   NewTkDAG(makeFrameTd) at '../Outputs/Lib/Dag/NewTkDAG/NewTkDAG.ozf'
   ModelParser(parse) at 'Parsers/ModelParser.ozf'
export
   View
prepare
   ListMapInd = List.mapInd
   RecordToList = Record.toList
define
   fun {FsISpecRec2Nodes FsISpecRec ModelSs}
      ModelXs =
      for S in ModelSs collect:Collect do
	 &%|& |S1 = S
	 Xs = {ModelParser.parse S1}
      in
	 case Xs
	 of [I word det#A] then
	    {Collect [I word A]}
	 [] [I1 DIDA model daughters fsvar#I2] then
	    Spec = FsISpecRec.I2
	    Is = {Helpers.spec2Is Spec}
	 in
	    {Collect [I1 DIDA model daughters Is]}
	 [] [I1 DIDA model daughtersL LA fsvar#I2] then
	    Spec = FsISpecRec.I2
	    Is = {Helpers.spec2Is Spec}
	 in
	    {Collect [I1 DIDA model daughtersL LA Is]}
	 [] [_ _ model det#o] then
	    {Collect Xs}
	 else
	    skip
	 end
      end
      ModelRec = {Helpers.unPickleRec ModelXs}
      Nodes = {RecordToList ModelRec}
   in
      Nodes
   end
   %%
   proc {View I FsISpecRec ModelSs DeleteProc}
      Nodes = {FsISpecRec2Nodes FsISpecRec ModelSs}
      %%
      DIDAs = {Filter {Arity Nodes.1}
	       fun {$ LI}
		  {Not {Member LI [entryIndex index pos nodeSet word]}}
	       end}
      %%
      Nodes1 = {ListMapInd Nodes
		fun {$ I Node}
		   o(index: I
		     string: o(text: Node.word))
		end}
      %%
      DIDANodes1EdgesTups =
      {Map DIDAs
       fun {$ DIDA}
	  LabeledEdges =
	  for Node in Nodes I1 in 1..{Length Nodes} collect:Collect do
	     if {HasFeature Node.DIDA model} andthen
		{HasFeature Node.DIDA.model daughtersL} then
		for LA in {Arity Node.DIDA.model.daughtersL} do
		   Is = Node.DIDA.model.daughtersL.LA
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
	  for Node in Nodes I1 in 1..{Length Nodes} collect:Collect do
	     if {HasFeature Node.DIDA model} andthen
		{HasFeature Node.DIDA.model daughters} then
		Is = Node.DIDA.model.daughters
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
	  DIDA#Nodes1#{Append LabeledEdges UnlabeledEdges}
       end}
      OptRec = o
      TitleV = 'ShowDAGs ('#I#')'
      ToplevelW = {New Tk.toplevel
		   if {IsProcedure DeleteProc} then
		      tkInit(title: TitleV
			     delete: DeleteProc)
		   else
		      tkInit(title: TitleV)
		   end}
      FrameW = {NewTkDAG.makeFrameTd DIDANodes1EdgesTups ToplevelW OptRec}
   in
      {Tk.batch [
		 grid(rowconfigure ToplevelW 0 weight:1)
		 grid(columnconfigure ToplevelW 0 weight:1)
		 grid(FrameW row:0 column:0 sticky:nswe)
		]}
   end
end
