%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   FD(reflect)
   FS(include)
export
   CIL2A

   As2V
define
   %% CIL2A: CIL -> A
   %% Transforms an IL constant CIL into the corresponding atom A.
   fun {CIL2A CIL} CIL.data end
   %% As2V: As V -> V1
   %% Transform list of atoms As into a virtual string V1, using
   %% virtual string V to "glue" to atoms together.
   fun {As2V As V}
      if As==nil then
	 ''
      else
	 A1|As1 = As
      in
	 {FoldR As1
	  fun {$ A AccV} AccV#V#A end A1}
      end
   end
end
