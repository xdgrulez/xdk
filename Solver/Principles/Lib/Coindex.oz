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
   ListTakeDrop = List.takeDrop
define
   proc {Constraint Nodes G Principle FD FS Select}
      DVA2DIDA = Principle.dVA2DIDA
      DIDA = {DVA2DIDA 'D'}
      for Node in Nodes do
	 Attrs = Node.DIDA.attrs
	 Entry = Node.DIDA.entry
      in
	 {FS.include Attrs.root.top.number Entry.root.top.number}
	 {FS.include Attrs.root.top.gender Entry.root.top.gender}
	 {FS.include Attrs.root.bot.number Entry.root.bot.number}
	 {FS.include Attrs.root.bot.gender Entry.root.bot.gender}
	 %%
	 {FS.include Attrs.subj.top.number Entry.subj.top.number}
	 {FS.include Attrs.subj.top.gender Entry.subj.top.gender}
	 {FS.include Attrs.subj.bot.number Entry.subj.bot.number}
	 {FS.include Attrs.subj.bot.gender Entry.subj.bot.gender}
	 %%
	 {FS.include Attrs.pred.top.number Entry.pred.top.number}
	 {FS.include Attrs.pred.top.gender Entry.pred.top.gender}
	 {FS.include Attrs.pred.bot.number Entry.pred.bot.number}
	 {FS.include Attrs.pred.bot.gender Entry.pred.bot.gender}
      end
      %%
      DIDA2EntryLat = G.dIDA2EntryLat
      EntryLat = {DIDA2EntryLat DIDA}
      ALatRec = EntryLat.record
      Lat = ALatRec.coindex
      TupLat = Lat.domain
      TupCardI = TupLat.card
      TupI2As = TupLat.i2AIs
   in
      for Node in Nodes do
	 Attrs = Node.DIDA.attrs
	 CoindexM = Node.DIDA.entry.coindex
      in
	 for I in 1..TupCardI do
	    As = {TupI2As I}
	    As1 As2
	    {ListTakeDrop As ({Length As} div 2) As1 As2}
	    D1 =
	    {FoldL As1
	     fun {$ AccX A1} AccX.A1 end Attrs}
	    D2 =
	    {FoldL As2
	     fun {$ AccX A2} AccX.A2 end Attrs}
	 in
	     {FD.impl
	      {FS.reified.include I CoindexM}
	      {FD.reified.equal D1 D2} 1}
	 end
      end
   end
end
