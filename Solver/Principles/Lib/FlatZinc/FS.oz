%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   Helpers(constraint branch cSP2FZ) at 'Helpers.ozf'
export
   Card
   Disjoint
   Distribute
   Equal
   Include
   Int
   Intersect
   Partition
   Reified
   Subset
   Union
   UnionN
   Value
   Var
define
   Constraint = Helpers.constraint
   Branch = Helpers.branch
   CSP2FZ = Helpers.cSP2FZ
   %%
   fun {Card CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'set_card' FZs}]
   end
   fun {Disjoint CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'set_intersect' [FZs.1 {Nth FZs 2} '{}']}]
   end
   fun {Distribute CSPs}
      [det(atom)#naive CSPFsetvec] = CSPs
      FZFsetarray = {CSP2FZ CSPFsetvec}
   in
      [{Branch 'set_search'
	[FZFsetarray '"none"' '"indomain_min"' '""']}]
   end
   fun {Equal CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'set_eq' FZs}]
   end
   fun {Include CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'set_in' FZs}]
   end
   Int = o(convex: fun {$ CSPs}
		      FZs = {Map CSPs CSP2FZ}
		   in
		      [{Constraint 'set_convex' FZs}]
		   end
	   seq: fun {$ CSPs}
		   FZs = {Map CSPs CSP2FZ}
		in
		   [{Constraint 'array_set_seq' FZs}]
		end
  
	  )
   fun {Intersect CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'set_intersect' FZs}]
   end
   fun {Partition CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'array_set_partition' FZs}]
   end
   Reified = o(equal: fun {$ CSPs}
			 FZs = {Map CSPs CSP2FZ}
		      in
			 [{Constraint 'set_eq_reif' FZs}]
		      end
	       include: fun {$ CSPs}
			   FZs = {Map CSPs CSP2FZ}
			in
			   [{Constraint 'set_in_reif' FZs}]
			end
	       subset: fun {$ CSPs}
			  FZs = {Map CSPs CSP2FZ}
		       in
			  [{Constraint 'set_subset_reif' FZs}]
		       end
	      )
   fun {Subset CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'set_subset' FZs}]
   end
   fun {Union CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'set_union' FZs}]
   end
   fun {UnionN CSPs}
      FZs = {Map CSPs CSP2FZ}
   in
      [{Constraint 'array_set_union' FZs}]
   end
   Value = o(make: fun {$ CSPs}
		      FZs = {Map CSPs CSP2FZ}
		      FZ1 =
		      case FZs.1
		      of '['#FZ#']' then '{'#FZ#'}'
		      else FZs.1
		      end
		   in
		      [{Constraint 'set_eq' [FZ1 {Nth FZs 2}]}]
		   end
	     singl: fun {$ CSPs}
		       FZs = {Map CSPs CSP2FZ}
		    in
		       [{Constraint 'set_in' FZs}
			{Constraint 'set_card' [{Nth FZs 2} 1]}]
		    end)
   Var = o(decl: fun {$ _}
		    nil
		 end
	   upperBound: fun {$ CSPs}
			  FZs = {Map CSPs CSP2FZ}
		       in
			  [{Constraint 'set_subset' [{Nth FZs 2} FZs.1]}]
		       end)
end
