%\define STRICT  % : good for debugging
functor
import
%   System(show:Show)
export
   GetSem
   GetSemLabel
   AdjoinAtSem
   EqSems
   GornAdjoin
   GornAdjoinFst
   GornAdjoinExt
   SinglGornDiff
   TraversedSems
   ConstantTree2A
   Sem2A
%   IsVarId
   ConstantTreeIsVar
   SemIsVar
   TokenIsVar
   SamePat
   Unify
   SemsOnly
   DeepMakeNeeded
   UnaryFunctionAdapter
prepare
   RecordMap = Record.map
   RecordForAll = Record.forAll
   RecordAllInd = Record.allInd
   V2A = VirtualString.toAtom
   V2S = VirtualString.toString
   ProcedureArity = Procedure.arity
define
   fun {GetSem X} {CondSelect X sem X} end

   fun {GetSemLabel X} {Label {GetSem X}} end

   fun {AdjoinAtSem T1 T2}
      T2Sem = if {IsFree T2} then thread {GetSem T2} end
	      else {GetSem T2} end
      X = if {HasFeature T1 sem} then {AdjoinAt T1 sem T2Sem} else T2 end
   in
      X
   end

   fun {EqSems X Y}
      if {IsRecord X} andthen {IsRecord Y} then 
	 XSem = {GetSem X}
	 YSem = {GetSem Y}
      in
	 ({IsRecord XSem} andthen {IsRecord YSem}
	  andthen {Label XSem} == {Label YSem}
	  andthen {Width XSem}  == {Width YSem}
	  andthen {RecordAllInd XSem
		   fun {$ I XSemSub} {EqSems XSemSub YSem.I} end})
	 orelse XSem == YSem 
      else X == Y end
   end

   fun {GornAdjoin Tree GornDiff}
      {GornAdjoinExt false Tree GornDiff}
   end

   fun {GornAdjoinFst Tree GornDiff}
      {GornAdjoinExt true Tree GornDiff}
   end

   fun {GornAdjoinExt Fst Tree GornDiff}
      case GornDiff
      of nil then Tree
      [] Cmd|Cmds then
	 FstRslt = {GornAdjoinExt Fst Tree Cmd}
      in
	 if Fst then FstRslt else {GornAdjoinExt Fst FstRslt Cmds} end
      [] replace(Tree1) then Tree1
      [] unify(Tree1) then
	 Tree = Tree1
	 Tree1
      [] unit then unit
      [] I#GornDiff then
	 Sem = {GetSem Tree}
	 NewSubtree = {GornAdjoinExt Fst Sem.I GornDiff}
	 NewSem = {AdjoinAt Sem I NewSubtree}
      in
	 {AdjoinAtSem Tree NewSem}
      elseif {IsProcedure GornDiff} then
	 GornDiff1 = case {ProcedureArity GornDiff}
		     of 1 then {GornDiff}
		     [] 2 then {GornDiff Tree} end
      in
	 {GornAdjoinExt Fst Tree GornDiff1}
      else
	 {Exception.raiseError badgorndiff(GornDiff)}
	 unit
      end
   end

   fun {SinglGornDiff Diff}
      case Diff of
	 nil then false
      [] SubDiff|Rest then Rest == nil andthen {SinglGornDiff SubDiff}
      [] _#SubDiff then {SinglGornDiff SubDiff}
      else true end
   end
   
   local
      proc {StrictTraverse Include Tree GornDiff Tail Rslt}
	 Rest
	 Sem = {GetSem Tree}
      in
	 Rslt = if Include then Sem|Rest else Rest end
	 case GornDiff
	 of nil then Rest = Tail
	 [] Diff|Diffs then Tail1 in
	    {Traverse false Sem Diff Tail1 Rest}
	    {Traverse false Sem Diffs Tail Tail1}
	 [] I#Diff then
	    {Traverse true Sem.I Diff Tail Rest}
	 else Rest = Tail end
      end
\ifdef STRICT
      Traverse = StrictTraverse
\else
      fun lazy {Traverse Include Tree GornDiff Tail}
	 {StrictTraverse Include Tree GornDiff Tail}
      end
\endif
   in
      fun {TraversedSems Tree GornDiff}
	 {Traverse true Tree GornDiff nil}
      end
   end
   
   %% ConstantTree2A: ConstantTree -> A
   %% Transforms ConstantTree into atom A.
   fun {ConstantTree2A ConstantTree}
      case ConstantTree
      of value(sem:Sem ...) then {Sem2A Sem}
      [] constant(A) then A
      end
   end
   %% Sem2A: Sem -> A
   %% Transforms Sem into atom A.
   fun {Sem2A Sem}
      case Sem
      of constant(token(sem:Sem1 ...)) then
	 {V2A Sem1}
      [] anno(ConstantTree ...) then
	 {ConstantTree2A ConstantTree}
      [] constant(value(sem:Sem1 ...)) then
	 {V2A Sem1}
      [] constant(A) then
	 A
      end
   end

   %% ConstantTreeIsVar: ConstantTree -> B
   %% Returns true if ConstantTree denotes a variable.
   fun {ConstantTreeIsVar ConstantTree}
      case ConstantTree
      of value(sem:Sem ...) then {SemIsVar Sem}
      [] constant(_) then true
      end
   end
   %% SemIsVar: Sem -> B
   %% Returns true if Sem denotes a variable.
   fun {SemIsVar Sem}
      case Sem
      of constant(token(...)) then {TokenIsVar Sem.1}
      [] constant(_) then true
      end
   end
   %% TokenIsVar: Token -> B
   %% Returns true if Token denotes a variable. Token is a variable
   %% if: 1) it is has been tokenized as an <id>, i.e., was *not*
   %% enclosed in single, double, or guillemet quotes, 2) begins with
   %% an uppercase letter followed by an arbitrary number of letters
   %% and digits.
   fun {TokenIsVar Token}
      V = Token.sem
      S = {V2S V}
   in
      {CondSelect Token sym '<id>'}=='<id>' andthen
      {Char.isAlpha S.1} andthen
      {Char.isUpper S.1} andthen
      {All S
       fun {$ Ch}
	  {Char.isAlpha Ch} orelse {Char.isDigit Ch}
       end}
   end

%    fun {ConstantTree2A Tree}
%       Sem = {GetSem Tree}
%    in
%       case {Width Sem} of
% 	 0 then Sem
%       [] 1 then {V2A {GetSem Sem.1}}
%       end
%    end
   
%    local
%       IsUpper = Char.isUpper
%       IsAlpha = Char.isAlpha
%       IsDigit = Char.isDigit
%       fun {IsAlnum Ch} {IsAlpha Ch} orelse {IsDigit Ch} end
%    in
%       fun {IsVarId VS}
% 	 S = {V2S VS}
%       in
% 	 {IsAlpha S.1} andthen {IsUpper S.1} andthen {All S.2 IsAlnum}
%       end
%    end
   
   proc {SamePat Feats SubPat Pat}
      Pat = {MakeRecord o Feats}
      {RecordForAll Pat fun {$} SubPat end}
   end
   
   fun {Unify T1 T2}
      if {Not {IsDet T1} andthen {IsDet T2}} then
	 T1 = T2
	 true
      elseif {IsRecord T1} andthen {IsRecord T2} then 
	 Sem1 = {GetSem T1}
	 Sem2 = {GetSem T2}
      in
	 ({IsRecord Sem1} andthen {IsRecord Sem2}
	  andthen {Label Sem1} == {Label Sem2}
	  andthen {Width Sem1} == {Width Sem2}
	  andthen {RecordAllInd Sem1 fun {$ I SubT1}
					{Unify SubT1 Sem2.I}
				     end})
	 orelse Sem1 == Sem2 
      else T1 == T2 end
   end

   fun {SemsOnly T} 
      if {IsRecord T} then
	 Sem = {GetSem T}
      in
	 if {IsRecord Sem} then
	    {RecordMap Sem SemsOnly}
	 else Sem end
      else T end
   end

   proc {DeepMakeNeeded X}
      if {IsRecord X} then
	 {RecordForAll X DeepMakeNeeded}
      end
   end
 
   fun {UnaryFunctionAdapter F}
      case {ProcedureArity F}
      of 3 then F
      [] 2 then fun {$ _ T} {F T} end
      end
   end
end