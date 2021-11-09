%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)
export
   Constraint
prepare
   ListToRecord = List.toRecord
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      %%
      DIDA = {DVA2DIDA 'D'}
      %% get label lattice LabelLat
      DIDA2LabelLat = G.dIDA2LabelLat
      LabelLat = {DIDA2LabelLat DIDA}
      LAs = LabelLat.constants
      %%
      Models = {Map Nodes fun {$ Node} Node.DIDA.model end}
      %%
      LADaughtersLMTups =
      {Map LAs
       fun {$ LA}
	  DaughtersLMs = {Map Models
			  fun {$ Model} Model.daughtersL.LA end}
	  DaughtersLM = {FS.unionN DaughtersLMs}
       in
	  LA#DaughtersLM
       end}
      LADaughtersLMRec = {ListToRecord o LADaughtersLMTups}
      %% get all eqdowns EqdownMs
      EqdownMs = {Map Models fun {$ Model} Model.eqdown end}
      %% get all equps EqupMs
      EqupMs = {Map Models fun {$ Model} Model.equp end}
   in
      for Model in Models I in 1..{Length Models} do
	 %% down(v) = union{ eqdown(v') | v' in daughters(v) }
	 Model.down = {Select.union EqdownMs Model.daughters}
	 %% up(v) = union{ equp(v') | v' in mothers(v) }
	 Model.up = {Select.union EqupMs Model.mothers}
	 %% daughters(v)={v} => down(v)={v}
	 {FD.impl
	  {FS.reified.equal Model.daughters Model.eq}
	  {FS.reified.equal Model.down Model.eq} 1}
      in
	 %% l in labels(v) iff v in { daughters_l(v') | v' in nodes }
	 for LA in LAs do
	    {FD.equi
	     {FS.reified.include {LabelLat.aI2I LA} Model.labels}
	     {FS.reified.include I LADaughtersLMRec.LA} 1}
	 end
      end
   end
end
