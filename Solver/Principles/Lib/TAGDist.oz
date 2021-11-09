functor
import
   Distributor(distributeDs distributeMs) at 'Distributor.ozf'
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
   in
      if {Helpers.checkModel 'TAGDist.oz' Nodes nil} then
	 DIDA = {DVA2DIDA 'D'}
	 %% distribute yield
	 YieldMs = {Map Nodes fun {$ Node} Node.DIDA.model.yield end}
      in
	 {Distributor.distributeMs YieldMs FS}
      end
   end
end
