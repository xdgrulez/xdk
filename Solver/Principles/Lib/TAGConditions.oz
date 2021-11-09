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
      if {Helpers.checkModel 'TAGConditions.oz' Nodes nil} then
	 for Node in Nodes do
	    DIDA2LabelLat = G.dIDA2LabelLat
	    LabelLat = {DIDA2LabelLat DIDA}
	    Model = Node.DIDA.model

	    %% get arguments
	    OrderIs = {ArgRecProc 'Order' o}
	    OrderLAs = {List.map OrderIs LabelLat.i2AI}

	    OrderedLeaveYields =
	    {List.map OrderLAs fun {$ L} Model.leaveYieldL.L end}
	 in
	    %% convexity principle
	    {FS.int.convex Model.yield}

	    for L in LabelLat.constants do
	       {FS.int.convex Model.yieldL.L}
	    end

	    %% order principle
	    {FS.int.seq OrderedLeaveYields}
	 end
      end
   end
end
