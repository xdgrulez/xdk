%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   FD
   FS
   Select at '../Solver/Principles/Lib/Select/Select.ozf'
export
   Get
define
   FD1 = {Adjoin FD
	  'export'(
	     equal: proc {$ Arg1 Arg2}
		       1 = (Arg1=:Arg2)
		    end
	     notequal: proc {$ Arg1 Arg2}
			  1 = (Arg1\=:Arg2)
		       end
	     reified:
		{Adjoin FD.reified
		 reified(equal: proc {$ Arg1 Arg2 Arg3}
				   Arg3 = (Arg1=:Arg2)
				end
			 greater: proc {$ Arg1 Arg2 Arg3}
				     Arg3 = (Arg1>:Arg2)
				  end
			 greatereq: proc {$ Arg1 Arg2 Arg3}
				       Arg3 = (Arg1>=:Arg2)
				    end
			 less: proc {$ Arg1 Arg2 Arg3}
				  Arg3 = (Arg1<:Arg2)
			       end
			 lesseq: proc {$ Arg1 Arg2 Arg3}
				    Arg3 = (Arg1=<:Arg2)
				 end
			 notequal: proc {$ Arg1 Arg2 Arg3}
				      Arg3 = (Arg1\=:Arg2)
				   end)})}
   FS1 = {Adjoin FS
	  'export'(equal: proc {$ Arg1 Arg2}
			     {FS.subset Arg1 Arg2}
			     {FS.subset Arg2 Arg1}
			  end
		   reified:
		      {Adjoin FS.reified
		       reified(subset:
				  proc {$ Arg1 Arg2 Arg3}
				     Arg3 = {FS.reified.equal {FS.intersect Arg1 Arg2} Arg1}
				  end
			       disjoint:
				  proc {$ Arg1 Arg2 Arg3}
				     Arg3 = {FS.reified.equal {FS.intersect Arg1 Arg2} FS.value.empty}
				  end)})}
   %%
   FunctorAFunctorRec =
   o('FD': FD1
     'FS': FS1
     'Select': Select)
   %%
   fun {Get} FunctorAFunctorRec end
end
