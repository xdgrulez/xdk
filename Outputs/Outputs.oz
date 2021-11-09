%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
%   Inspector(inspect)

   FS(value reflect unionN diff)

   Helpers(dIDAPosSort) at 'Helpers.ozf'

   Decode(decode) at 'Decode.ozf'
   Pretty(pretty) at 'Pretty.ozf'
   Edges(get) at 'Edges.ozf'
   Index2Pos(get) at 'Index2Pos.ozf'
export
   Outputs
   Open
   Close
define
   Outputs = [
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.allDags')
		   'functor': elem(tag: constant
				   data: 'AllDags'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.allDags1')
		   'functor': elem(tag: constant
				   data: 'AllDags1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.allDags2')
		   'functor': elem(tag: constant
				   data: 'AllDags2'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.allDags3')
		   'functor': elem(tag: constant
				   data: 'AllDags3'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.allLatexs')
		   'functor': elem(tag: constant
				   data: 'AllLatexs'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.allLatexs1')
		   'functor': elem(tag: constant
				   data: 'AllLatexs1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.allLatexs2')
		   'functor': elem(tag: constant
				   data: 'AllLatexs2'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.allLatexs3')
		   'functor': elem(tag: constant
				   data: 'AllLatexs3'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.clls')
		   'functor': elem(tag: constant
				   data: 'CLLS'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.clls1')
		   'functor': elem(tag: constant
				   data: 'CLLS1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.dag')
		   'functor': elem(tag: constant
				   data: 'Dag'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.dag1')
		   'functor': elem(tag: constant
				   data: 'Dag1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.dag2')
		   'functor': elem(tag: constant
				   data: 'Dag2'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.dag3')
		   'functor': elem(tag: constant
				   data: 'Dag3'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.dags')
		   'functor': elem(tag: constant
				   data: 'Dags'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.dags1')
		   'functor': elem(tag: constant
				   data: 'Dags1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.dags2')
		   'functor': elem(tag: constant
				   data: 'Dags2'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.dags3')
		   'functor': elem(tag: constant
				   data: 'Dags3'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.decode')
		   'functor': elem(tag: constant
				   data: 'Decode'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.latex')
		   'functor': elem(tag: constant
				   data: 'Latex'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.latex1')
		   'functor': elem(tag: constant
				   data: 'Latex1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.latex2')
		   'functor': elem(tag: constant
				   data: 'Latex2'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.latex3')
		   'functor': elem(tag: constant
				   data: 'Latex3'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.latexs')
		   'functor': elem(tag: constant
				   data: 'Latexs'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.latexs1')
		   'functor': elem(tag: constant
				   data: 'Latexs1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.latexs2')
		   'functor': elem(tag: constant
				   data: 'Latexs2'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.latexs3')
		   'functor': elem(tag: constant
				   data: 'Latexs3'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.pretty')
		   'functor': elem(tag: constant
				   data: 'Pretty'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.pretty1')
		   'functor': elem(tag: constant
				   data: 'Pretty1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.xml')
		   'functor': elem(tag: constant
				   data: 'XML'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.xml1')
		   'functor': elem(tag: constant
				   data: 'XML1'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.xml2')
		   'functor': elem(tag: constant
				   data: 'XML2'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.xml3')
		   'functor': elem(tag: constant
				   data: 'XML3'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.xml4')
		   'functor': elem(tag: constant
				   data: 'XML4'))
	      %%
	      elem(tag: outputdef
		   id: elem(tag: constant
			    data: 'output.xTAGDerivation')
		   'functor': elem(tag: constant
				   data: 'XTAGDerivation'))
	     ]
   %% Open: G PrintProc -> Proc
   %% Returns procedure Proc: I Nodes -> U for grammar G and print
   %% procedure PrintProc.  Proc calls all used open output procedures
   %% for solution I (nodes Nodes).
   fun {Open G PrintProc}
      UsedDIDAs = G.usedDIDAs
      UsedOns = G.usedOns
      OnOutputTups = G.onOutputTups
      %% create open procedure
      Proc =
      proc {$ I Nodes}
	 NodeILs = {Decode.decode Nodes G}
	 NodeOLs = {Pretty.pretty Nodes G false}
	 NodeOLAbbrs = {Pretty.pretty Nodes G true}
	 UsedGraphDIDAs =
	 {Filter UsedDIDAs
	  fun {$ DIDA}
	     NodeOL = NodeOLs.1
	  in
	     {HasFeature NodeOL.DIDA.model daughters} andthen
	     {HasFeature NodeOL.DIDA.model daughtersL} andthen
	     {HasFeature NodeOL.DIDA.model down}
	  end}
	 Edges1 = {Edges.get Nodes G}
	 Index2Pos1 = {Index2Pos.get Nodes}
	 OutputRec = o(usedDIDAs: UsedDIDAs
		       usedGraphDIDAs: UsedGraphDIDAs
		       nodes: Nodes
		       nodeILs: NodeILs
		       nodeOLs: NodeOLs
		       nodeOLAbbrs: NodeOLAbbrs
		       index2Pos: Index2Pos1
		       printProc: PrintProc
		       edges: Edges1)
      in
	 for On#Output in OnOutputTups do
	    if {Member On UsedOns} then
	       DIDA = Output.dIDA
	       OpenProc = Output.open
	    in
	       if {Member DIDA UsedDIDAs} then
		  {OpenProc DIDA I OutputRec}
	       end
	    end
	 end
      end
   in
      Proc
   end
   %% Close: G -> Proc
   %% Returns procedure Proc: U -> U for grammar G. Proc calls *all*
   %% (not only the currently used but all) close output procedures.
   fun {Close G}
      UsedDIDAs = G.usedDIDAs
      UsedOns = G.usedOns
      OnOutputTups = G.onOutputTups
      %% create close procedure
      Proc =
      proc {$}
	 for On#Output in OnOutputTups do
	    if {Member On UsedOns} then
	       DIDA = Output.dIDA
	       CloseProc = Output.close
	    in
	       if {Member DIDA UsedDIDAs} then
		  {CloseProc DIDA}
	       end
	    end
	 end
      end
   in
      Proc
   end
end
