%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Helpers(checkModel) at 'Helpers.ozf'
export
   Constraint
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      ArgRecProc = Principle.argRecProc
      %%
      D1DIDA = {DVA2DIDA 'D1'}
      D2DIDA = {DVA2DIDA 'D2'}
      DIDA2LabelLat = G.dIDA2LabelLat
      D1LabelLat = {DIDA2LabelLat D1DIDA}
      D1LAs = D1LabelLat.constants
      D2LabelLat = {DIDA2LabelLat D2DIDA}
      D2LAs = D2LabelLat.constants
   in
      %% check features
      if {Helpers.checkModel 'Locking.oz' Nodes
	  [D2DIDA#mothers
	   D2DIDA#mothersL
	   D1DIDA#daughtersL
	   D1DIDA#upL
	   D1DIDA#eq]} then
	 D2MothersMs =
	 {Map Nodes
	  fun {$ Node} Node.D2DIDA.model.mothers end}
	 %%
	 D2MothersLMs =
	 {Map D2LAs
	  fun {$ LA}
	     {FS.unionN
	      {Map Nodes
	       fun {$ Node} Node.D2DIDA.model.mothersL.LA end}}
	  end}
      in
	 for Node in Nodes do
	    LockDaughtersD1LM = {ArgRecProc 'LockDaughters' o('_': Node)}
	    ExceptAboveD1LM = {ArgRecProc 'ExceptAbove' o('_': Node)}
	    KeyD2LM = {ArgRecProc 'Key' o('_': Node)}
	    %%
	    D1DaughtersLMs = {Map D1LAs
			      fun {$ LA} Node.D1DIDA.model.daughtersL.LA end}
	    LockDaughtersM = {Select.union D1DaughtersLMs LockDaughtersD1LM}
	    %%
	    D1UpLMs = {Map D1LAs
		       fun {$ LA} Node.D1DIDA.model.upL.LA end}
	    ExceptAboveM = {Select.union D1UpLMs ExceptAboveD1LM}
	    %%
	    KeyM = {Select.union D2MothersLMs KeyD2LM}
	    %%
	    D2MothersLockDaughtersM =
	    {Select.union D2MothersMs LockDaughtersM}
	 in
	    {FS.subset D2MothersLockDaughtersM
	     {FS.unionN [Node.D1DIDA.model.eq ExceptAboveM KeyM]}}
	 end
      end
   end
end
