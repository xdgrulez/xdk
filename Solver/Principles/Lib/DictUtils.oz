%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   System(eq:SystemEq)
export
   DeepCondExchange
   DeepCondAccess
   DeepAccess
   CondPut
   Lookup
prepare
   DictCondExchange = Dictionary.condExchange
   Noth = {NewName}
define
   proc {DeepCondExchange D Ks DefV OldV NewV}
      case Ks
      of [K] then
	 {DictCondExchange D K DefV OldV NewV}
      [] K|Ks then OldD NewD in 
	 {DictCondExchange D K unit OldD NewD}
	 NewD = if {IsUnit OldD} then {NewDictionary} else OldD end
	 {DeepCondExchange NewD Ks DefV OldV NewV}
      end
   end
   proc {DeepCondAccess D Ks DefV V} {DeepCondExchange D Ks DefV V V} end
   proc {DeepAccess D Ks V} {DeepCondAccess D Ks V V} end
   proc {CondPut D K V}
      {DictCondExchange D K V V V}
   end
   proc {Lookup D K IsNew V} OldV in
      {DictCondExchange D K Noth OldV V}
      if {SystemEq Noth OldV} then IsNew = true else
	 IsNew = false
	 OldV = V
      end
   end
end