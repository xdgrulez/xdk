%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Helpers(var constraint branch cSP2FZ xs2X) at 'Helpers.ozf'
export
   Conj
   Disj
   Distribute
   Equal
   Equi
   Greatereq
   Impl
   Int
   Lesseq
   Nega
   Reified
   Sum
prepare
   ListMake = List.make
define
   Var = Helpers.var
   Constraint = Helpers.constraint
   Branch = Helpers.branch
   CSP2FZ = Helpers.cSP2FZ
   Xs2X = Helpers.xs2X
   %%
   fun {Conj CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'bool_and' FZs}]
   end
   fun {Disj CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'bool_or' FZs}]
   end
   fun {Distribute CSPs}
      [det(atom)#ff CSPIntvec] = CSPs
      FZIntarray = {CSP2FZ CSPIntvec}
   in
      [{Branch 'int_search'
	[FZIntarray '"first_fail"' '"indomain_min"' '""']}]
   end
   fun {Equal CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'int_eq' FZs}]
   end
   fun {Equi CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'bool_eq_reif' FZs}]
   end
   fun {Greatereq CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'int_ge' FZs}]
   end
   fun {Impl CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'bool_right_imp' FZs}]
   end
   fun {Int CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Var int#FZs.1}]
   end
   fun {Lesseq CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'int_le' FZs}]
   end
   fun {Nega CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'bool_not' FZs}]
   end
   Reified =
   o(equal: fun {$ CSPs}
	       FZs = {Map CSPs CSP2FZ}
	    in
	       [{Constraint 'int_eq_reif' FZs}]
	    end
     greater: fun {$ CSPs}
		 FZs = {Map CSPs CSP2FZ}
	      in
		 [{Constraint 'int_gt_reif' FZs}]
	      end
     greatereq: fun {$ CSPs}
		   FZs = {Map CSPs CSP2FZ}
		in
		   [{Constraint 'int_ge_reif' FZs}]
		end
     less: fun {$ CSPs}
	      FZs = {Map CSPs CSP2FZ}
	   in
	      [{Constraint 'int_lt_reif' FZs}]
	   end
     lesseq: fun {$ CSPs}
		FZs = {Map CSPs CSP2FZ}
	     in
		[{Constraint 'int_le_reif' FZs}]
	     end
     notequal: fun {$ CSPs}
		  FZs = {Map CSPs CSP2FZ}
	       in
		  [{Constraint 'int_ne_reif' FZs}]
	       end
     sum: fun {$ CSPs}
	     [CSPIntvec det(atom)#A CSPInt CSPBool] = CSPs
	     FZIntarray1 = {CSP2FZ CSPIntvec}
	     CSPIntvecI =
	     if {IsList CSPIntvec} then {Length CSPIntvec}
	     else {Width CSPIntvec}
	     end
	     Is = {ListMake CSPIntvecI}
	     for I in Is do I=1 end
	     FZIntarray2 = '['#{Xs2X Is ','}#']'
	     FZInt = {CSP2FZ CSPInt}
	     FZBool = {CSP2FZ CSPBool}
	  in
	     case A
	     of '=:' then
		[{Constraint 'int_lin_eq_reif' [FZIntarray1 FZIntarray2 FZInt FZBool]}]
	     [] '\\=:' then
		[{Constraint 'int_lin_ne_reif' [FZIntarray1 FZIntarray2 FZInt FZBool]}]
	     [] '=<:' then
		[{Constraint 'int_lin_le_reif' [FZIntarray1 FZIntarray2 FZInt FZBool]}]
	     [] '<:' then
		[{Constraint 'int_lin_lt_reif' [FZIntarray1 FZIntarray2 FZInt FZBool]}]
	     [] '>=:' then
		[{Constraint 'int_lin_ge_reif' [FZIntarray1 FZIntarray2 FZInt FZBool]}]
	     [] '>:' then
		[{Constraint 'int_lin_gt_reif' [FZIntarray1 FZIntarray2 FZInt FZBool]}]
	     end
	  end)
   fun {Sum CSPs}
      [CSPIntvec det(atom)#A CSPInt] = CSPs
      FZIntarray1 = {CSP2FZ CSPIntvec}
      CSPIntvecI =
      if {IsList CSPIntvec} then {Length CSPIntvec}
      else {Width CSPIntvec}
      end
      Is = {ListMake CSPIntvecI}
      for I in Is do I=1 end
      FZIntarray2 = '['#{Xs2X Is ','}#']'
      FZInt = {CSP2FZ CSPInt}
   in
      case A
      of '=:' then
	 [{Constraint 'int_lin_eq' [FZIntarray1 FZIntarray2 FZInt]}]
      [] '\\=:' then
	 [{Constraint 'int_lin_ne' [FZIntarray1 FZIntarray2 FZInt]}]
      [] '=<:' then
	 [{Constraint 'int_lin_le' [FZIntarray1 FZIntarray2 FZInt]}]
      [] '<:' then
	 [{Constraint 'int_lin_lt' [FZIntarray1 FZIntarray2 FZInt]}]
      [] '>=:' then
	 [{Constraint 'int_lin_ge' [FZIntarray1 FZIntarray2 FZInt]}]
      [] '>:' then
	 [{Constraint 'int_lin_gt' [FZIntarray1 FZIntarray2 FZInt]}]
      end
   end
end
