%% Copyright 2004-2011
%% by Ondrej Bojar <obo@cuni.cz>
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
      AttrsLat = {G.dIDA2AttrsLat DIDA}
      ALatRec = AttrsLat.record
      AgrReqLat = ALatRec.agrreq
      AgrReqAs = AgrReqLat.constants
   in
      %% check features
      if {Helpers.checkModel 'LookRight.oz' Nodes
          [DIDA#labels]} then
         for Node in Nodes I in 1..{Length Nodes} do
            LookRightRec = {ArgRecProc 'LookRight' o('_': Node)}
            Index1 = I+1
	    N = {Length Nodes}
            %% right neighbour's agr must allow our edge label,
            %% i.e. our edge label in ...
	    AllowedLabelsM =
	    if Index1 =< N then
	       Node1 = {Nth Nodes Index1}
	       AgrReqD = Node1.DIDA.attrs.agrreq
	    in
	       {Select.fs
		{Map AgrReqAs fun {$ A} LookRightRec.A end}
		AgrReqD}
	    else
	       LookRightRec.'-1'
	    end
	 in
	    {FS.subset Node.DIDA.model.labels AllowedLabelsM}
         end
      end
   end
end
