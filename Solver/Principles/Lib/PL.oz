%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      NodeSetM = Nodes.1.nodeSet
      %%
      DIDA = {DVA2DIDA 'D'}
   in
      %% check features
      if {Helpers.checkModel 'PL.oz' Nodes
	  [DIDA#mothers
	   DIDA#daughtersL
	   DIDA#daughters]} then
	 for Node in Nodes do
	    {FS.include Node.DIDA.attrs.bars NodeSetM}
	 end
	 %% Roots:
	 %% not exists v': v' -> v => (PL v).truth(v)=2
	 for Node in Nodes do
	    {FD.impl
	     {FD.reified.equal {FS.card Node.DIDA.model.mothers} 0}
	     {FD.reified.equal Node.DIDA.attrs.truth 2} 1}
	 end
	 %% Implications:
	 %% v -arg1-> v' and v -arg2-> v'' =>
	 %%   (PL v).truth=((PL v').truth => (PL v'').truth)+1 and
	 %%   (PL v).bars=1
	 for Node in Nodes do
	    for Node1 in Nodes do
	       for Node2 in Nodes do
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node1.index Node.DIDA.model.daughtersL.arg1}
		    {FS.reified.include Node2.index Node.DIDA.model.daughtersL.arg2}}
		   {FD.reified.sum
		    [{FD.reified.lesseq
		      Node1.DIDA.attrs.truth
		      Node2.DIDA.attrs.truth} 1] '=:' Node.DIDA.attrs.truth} 1}

		  %%
		  {FD.impl
		   {FD.conj
		    {FS.reified.include Node1.index Node.DIDA.model.daughtersL.arg1}
		    {FS.reified.include Node2.index Node.DIDA.model.daughtersL.arg2}}
		   {FD.reified.equal Node.DIDA.attrs.bars 1} 1}
	       end
	    end
	 end
	 %% Zeros:
	 %% forall v: (w v)=0 => (PL v).truth=1 and (PL v).bars=1
	 for Node in Nodes do
	    if Node.word=='0' then
	       {FD.equal Node.DIDA.attrs.truth 1}
	       {FD.equal Node.DIDA.attrs.bars 1}
	    end
	 end
	 %% Variables:
	 %% forall v, v': (w v)=var => v -bar-> v' =>
	 %%   (PL v).bars=(PL v').bars
	 for Node1 in Nodes do
	    if Node1.word=='var' then
	       for Node2 in Nodes do
		  {FD.impl
		   {FS.reified.include Node2.index Node1.DIDA.model.daughtersL.bar}
		   {FD.reified.equal
		    Node1.DIDA.attrs.bars Node2.DIDA.attrs.bars} 1}
	       end
	    end
	 end
	 %% Bars:
	 %% forall v: (w v)=I => (PL v).truth=1 and
	 %%   not exists v': v -> v' => (PL v).bars=1 and
	 %%   (forall v': v -bar-> v' => (PL v').bars < (PL v).bars and
	 %%    not exists v'': (PL v').bars<v'' and v''<(PL v).bars)
	 %%
	 %% last line equivalent to:
	 %%   forall v'': (not (PL v').bars<v'') or (not v''<(PL v).bars)
	 %% which is equivalent to:
	 %%   forall v'': (PL v').bars>=v'' or v''>=(PL v).bars
	 for Node1 in Nodes do
	    if Node1.word=='I' then
	       {FD.equal Node1.DIDA.attrs.truth 1}
	       %%
	       {FD.impl
		{FD.reified.equal {FS.card Node1.DIDA.model.daughters} 0}
		{FD.reified.equal Node1.DIDA.attrs.bars 1} 1}
	       %%
	       for Node2 in Nodes do
		  for Node3 in Nodes do
		     {FD.impl
		      {FS.reified.include Node2.index Node1.DIDA.model.daughtersL.bar}
		      {FD.conj
		       {FD.reified.less Node2.DIDA.attrs.bars Node1.DIDA.attrs.bars}
		       {FD.disj
			{FD.reified.greatereq Node2.DIDA.attrs.bars Node3.index}
			{FD.reified.greatereq Node3.index Node1.DIDA.attrs.bars}}} 1}
		  end
	       end
	    end
	 end
	 %% Coreference:
	 %% forall v, v': (w v)=var and (w v')=var =>
	 %%   (PL v).bars=(PL v').bars => (PL v).truth=(PL v').truth
	 for Node1 in Nodes do
	    for Node2 in Nodes do
	       if Node1.word=='var' andthen Node2.word=='var' then
		  {FD.impl
		   {FD.reified.equal Node1.DIDA.attrs.bars Node2.DIDA.attrs.bars}
		   {FD.reified.equal Node1.DIDA.attrs.truth Node2.DIDA.attrs.truth} 1}
	       end
	    end
	 end
      end
   end
end
