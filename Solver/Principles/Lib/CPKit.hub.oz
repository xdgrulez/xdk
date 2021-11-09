%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Kit1 at 'CPKit.nomemo.ozf'
   Kit2 at 'CPKit.memo.noshared.collapsed.dicts.ozf'
   Kit3 at 'CPKit.memo.shared.asis.recs.ozf'
   Kit4 at 'CPKit.memo.shared.collapsed.recs.ozf'
   Kit5 at 'CPKit.memo.shared.collapsed.dicts.ozf'
   Kit6 at 'CPKit.memo.noshared.atomized.dicts.ozf'
export
   Kits
   Options
   OptionsStr
   Option2KitRec
   Option2Kit
   OptionDef
prepare
   L2R = List.toRecord
   L2T = List.toTuple
   LZip = List.zip
define
   Kits =
   [
    Kit1
    Kit2
    Kit3
    Kit4
    Kit5
    Kit6
   ]

   Options = {Map Kits fun {$ Kit} Kit.option end}
   OptionsStr = Options.1#{L2T '#' {Map Options.2 fun {$ Opt} '|'#Opt end}}
   OptionDef = {L2T atom Options}
   Option2KitRec = {L2R o {LZip Options Kits fun {$ X Y} X#Y end}}
   fun {Option2Kit Opt} Option2KitRec.Opt end
end