%% Copyright 2004-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University)
%%    Ondrej Bojar <obo@cuni.cz>
%%
functor
import
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
      %% check features
      if {Helpers.checkModel 'Customs.oz' Nodes
          [DIDA#labels DIDA#daughters DIDA#down]} then
         for Node in Nodes do
           if Node.index > 1 andthen
	      Node.index < {Length Nodes}
           then
             AllowedOverEdges = {ArgRecProc 'Customs' o('_': Node)}
             DaughtersMs = {Map Nodes fun {$ A} A.DIDA.model.daughters end}
             LabelsMs = {Map Nodes fun {$ A} A.DIDA.model.labels end}
             ML = {FS.value.make [1#(Node.index-1)]}
               % nodes left of me
             MLAbove = {FS.diff ML Node.DIDA.model.down}
               % nodes left of me and not below me
             MR = {FS.value.make [(Node.index+1)#{Length Nodes}]}
             MRAbove = {FS.diff MR Node.DIDA.model.down}
             MLSons = {Select.union DaughtersMs MLAbove}
	       % sons of nodes left of me
	     MRL = {FS.intersect MLSons MR}
               % nodes right of me that have the father left of me
             LabsRL = {Select.union LabelsMs MRL}
               % labels of such edges
             MRSons = {Select.union DaughtersMs MRAbove}
               % nodes left of me that have the father right of me
	       % sons of nodes left of me
	     MLR = {FS.intersect MRSons ML}
             LabsLR = {Select.union LabelsMs MLR}
               % labels of such edges
             in
               {FS.subset LabsLR AllowedOverEdges}
               {FS.subset LabsRL AllowedOverEdges}
           end % if
         end
      end
   end
end
