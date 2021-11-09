%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   FS(value)

   Helpers(constraint cSP2FZ) at 'Helpers.ozf'
export
   Fd
   Fs
   Union
   SeqUnion
   The
define
   Constraint = Helpers.constraint
   CSP2FZ = Helpers.cSP2FZ
   %%
   fun {Fd CSPs}
      X#Xs = CSPs.1
      FZ1 = {CSP2FZ X#(det(int)#0|Xs)}
      FZ2 = {CSP2FZ {Nth CSPs 2}}
      FZ3 = {CSP2FZ {Nth CSPs 3}}
   in
      [{Constraint 'array_int_element' [FZ2 FZ1 FZ3]}]
   end
   fun {Fs CSPs}
      X#Xs = CSPs.1
      FZ1 = {CSP2FZ X#(det(fset)#FS.value.empty|Xs)}
      FZ2 = {CSP2FZ {Nth CSPs 2}}
      FZ3 = {CSP2FZ {Nth CSPs 3}}
   in
      [{Constraint 'array_var_set_element' [FZ2 FZ1 FZ3]}]
   end
   fun {Union CSPs}
      X#Xs = CSPs.1
      FZ1 = {CSP2FZ X#(det(fset)#FS.value.empty|Xs)}
      FZ2 = {CSP2FZ {Nth CSPs 2}}
      FZ3 = {CSP2FZ {Nth CSPs 3}}
   in
      [{Constraint 'array_var_set_element_union' [FZ2 FZ1 FZ3]}]
   end
   fun {SeqUnion CSPs}
      FZ1 = {CSP2FZ CSPs.1}
      FZ2 = {CSP2FZ {Nth CSPs 2}}
   in
      [{Constraint 'array_set_seq_union' [FZ1 FZ2]}]
   end
   fun {The CSPs}
      FZ1 = {CSP2FZ CSPs.1}
      FZ2 = {CSP2FZ {Nth CSPs 2}}
   in
%      [{Constraint 'set_int_eq' [FZ1 FZ2]}]
%      set_int_eq(x,y) => set_in(y,x) /\ set_card(x,1)
      [{Constraint 'set_in' [FZ2 FZ1]}
       {Constraint 'set_card' [FZ1 1]}]
   end
end
