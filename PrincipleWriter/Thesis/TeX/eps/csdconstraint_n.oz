proc {Constraint Nodes G GetDim}
   DIDA = {GetDim 'D'}
   PosMs = {Map Nodes 
	    fun {$ Node} Node.pos end}
in
   for Node in Nodes do
      NDaughtersMs = 
      {Map Nodes
       fun {$ Node} Node.DIDA.model.daughtersL.n end}
      NDaughtersUpM = {Select.union NDaughtersMs Node.DIDA.model.up}
      PosNDaughtersUpM = {Select.union PosMs NDaughtersUpM}
      NDaughtersM = Node.DIDA.model.daughtersL.n
      PosNDaughtersM = {Select.union PosMs NDaughtersM}
   in
      {FS.int.seq [PosNDaughtersUpM PosNDaughtersM]}
   end
end
