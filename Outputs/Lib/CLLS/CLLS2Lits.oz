%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
export
   Convert
prepare
   ListToTuple = List.toTuple
define
   A2S = Atom.toString
   B2S = ByteString.toString
   S2A = String.toAtom
   %% Convert: CLLS Proc AnchorA -> Lits
   %% Converts parsed CLLS literals CLLS into the corresponding list
   %% of CLLS literals Lits. Proc: A -> A is used to make node
   %% variables unique. AnchorA is the anchor of the set of literals
   %% (e.g. love').
   fun {Convert CLLS Proc AnchorA}
      Coord = CLLS.coord
      File = CLLS.file
      Sem = CLLS.sem
   in
      case Sem
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% dom
      of dom(CLLS1 CLLS2) then
	 VarA1 = {Convert CLLS1 Proc AnchorA}
	 VarA2 = {Convert CLLS2 Proc AnchorA}
      in
	 dom(VarA1 VarA2)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% label
      [] label(CLLS1 CLLS2 CLLS3) then
	 VarA = {Convert CLLS1 Proc AnchorA}
	 ConstA = {Convert CLLS2 Proc AnchorA}
	 VarAs = {Convert CLLS3 Proc AnchorA}
	 Rec = {ListToTuple ConstA VarAs}
      in
	 label(VarA Rec)
      [] label(CLLS1 CLLS2) then
	 VarA = {Convert CLLS1 Proc AnchorA}
	 ConstA = {Convert CLLS2 Proc AnchorA}
      in
	 label(VarA ConstA)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% lam
      [] lam(CLLS1 CLLS2) then
	 VarA1 = {Convert CLLS1 Proc AnchorA}
	 VarA2 = {Convert CLLS2 Proc AnchorA}
      in
	 lam(VarA1 VarA2)
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% const
      [] const(CLLS) then
	 Sym = CLLS.sym
	 Sem = CLLS.sem
	 S =
	 case Sym
	 of '<id>' then
	    {A2S Sem}
	 elseif Sym=='<sstring>' orelse Sym=='<dstring>' orelse Sym=='<gstring>' then
	    {B2S Sem}
	 end
	 A = {S2A S}
	 %% make node variables (beginning with "x" or "X") unique
	 %% using Proc: A -> A
	 A1 =
	 if S.1==&x orelse S.1==&X then
	    {Proc A}
	 else
	    A
	 end
      in
	 A1
	 %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%
	 %% sem
      [] anchor(...) then
	 AnchorA
      elseif {IsList Sem} then
	 {Map Sem
	  fun {$ CLLS} {Convert CLLS Proc AnchorA} end}
      else
	 raise error1('functor':'Outputs/Lib/CLLS/CLLS2Lits.ozf' 'proc':'Convert' msg:'Illformed CLLS expression.' info:o(CLLS) coord:Coord file:File) end
	 
      end
   end
end
