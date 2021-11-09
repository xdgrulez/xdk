%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
export
   CheckCycles
   
   FillRec

   IsSubset

   AppendList

   MSpec2Is

   Escape
prepare
   RecordMapInd = Record.mapInd
define
   %% CheckCycles: DIDA NodeOLs -> U
   %% Raises an exception if a cycle is detected on dimension DIDA in
   %% nodes Nodes.
   proc {CheckCycles DIDA NodeOLs}
      proc {CheckCycles1 NodeOL Is}
	 I = NodeOL.index
      in
	 case Is
	 of nil then
	    skip
	 [] I1|Is1 then
	    if I1==I then
	       raise error1('functor':'Outputs/Lib/Latex/Helpers.ozf' 'proc':'CheckCycles1' msg:'Cycle detected: '#I1 info:o(I1) coord:noCoord file:noFile) end
	    else
	       {CheckCycles1 NodeOL Is1}
	    end
	 end
      end
   in
      for NodeOL in NodeOLs do
	 Is = {CondSelect NodeOL.DIDA.model daughters nil}
      in
	 case Is
	 of '_'(LBMSpec ...) then
	    LBIs = {MSpec2Is LBMSpec}
	 in
	    {CheckCycles1 NodeOL LBIs}
	 else
	    {CheckCycles1 NodeOL Is}
	 end
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% FillRec: Rec1 Rec2 -> Rec
   %% Recursively fills Rec1 with values from Rec2 for each field not
   %% present in Rec1. Can be used e.g. for filling options records
   %% (Rec1) with default values (Rec2).
   fun {FillRec Rec1 Rec2}
      {RecordMapInd Rec2
       fun {$ LI X}
	  if {HasFeature Rec1 LI} then
	     if {IsRecord X} andthen {Not {Arity X}==nil} then
		{FillRec Rec1.LI X}
	     else
		Rec1.LI
	     end
	  else
	     Rec2.LI
	  end
       end}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% IsSubset: Xs Ys -> B
   %% Returns true if Xs denotes a subset of Ys, and false if not.
   fun {IsSubset Xs Ys}
      {All Xs
       fun {$ X} {Member X Ys} end}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% AppendList: Xss -> Xs
   %% Appends lists Xss in order to yield list Xs.
   fun {AppendList Xss}
      {FoldL Xss
       fun {$ AccXs Xs} {Append AccXs Xs} end nil}
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% The syntax of a description of a finite set of integers is:
   %%    set_descr   ::= simpl_descr | compl(simpl_descr)
   %%    simpl_descr ::= range_descr | nil | [range_descr+]
   %%    range_descr ::= integer | integer#integer
   %%    integer     ::= {0,...,134 217 726}
   fun {MSpec2Is MSpec}
      Is =
      case MSpec
      of compl(...) then nil
      [] I1#I2 then
	 for I in I1..I2 collect:Collect do {Collect I} end
      elseif {IsList MSpec} then
	 for MSpec1 in MSpec append:Append do
	    Is1 = {MSpec2Is MSpec1}
	 in
	    {Append Is1}
	 end
      elseif {IsInt MSpec} then
	 [MSpec]
      else
	 raise error1('functor':'Outputs/Lib/Helpers.ozf' 'proc':'MSpec2Is' msg:'Illformed MSpec.' info:o(MSpec) coord:noCoord file:noFile) end
      end
   in
      Is
   end
   %%
   %% Escape: A -> A
   %% Add escape characters for LaTeX special characters such as $ and &.
   %%
   A2S = Atom.toString
   %%
   S2A = String.toAtom
   %%
   EscapeChs = [&$ && &% &# &_ &{ &}]
   %%
   fun {Escape A}
      S = {A2S A}
      S1 = {Escape1 S}
      A1 = {S2A S1}
   in
      A1
   end
   %%
   fun {Escape1 S}
      case S
      of nil then nil
      [] &~|S1 then &$|&\\|&s|&i|&m|&$|{Escape1 S1}
      [] &^|S1 then &$|&^|&\\|&w|&e|&d|&g|&e|&$|{Escape1 S1}
      [] &\\|S1 then &$|&\\|&b|&a|&c|&k|&s|&l|&a|&s|&h|&$|{Escape S1}
      [] Ch|S1 then
	 if {Member Ch EscapeChs} then
	    &\\|Ch|{Escape1 S1}
	 else
	    Ch|{Escape1 S1}
	 end
      end
   end
end
