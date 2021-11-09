%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   FS
   DictUtils(lookup:Lookup) at 'DictUtils.ozf'
export
   mkNew:MkNewMemoizer
   Decheck
   EnsureDecheck
   Dict
   KeyChangeDict
prepare
   RecordMap = Record.map
define
   Error = Exception.raiseError
  
   fun {Id X} X end
   fun {Const X} fun {$ _} X end end

   fun {Decheck X}
      case X of trivial(Y) then Y else {X} end
   end
   local
      Test = trivial(1)
   in
      fun {EnsureDecheck Decheck}
	 if {Decheck Test} == Test then Decheck else Id end
      end
   end

   fun {MkProxy InnerProc OuterProc}
      Ari = {ProcedureArity OuterProc}
   in
      case Ari
      of 1 then
	 proc {$ A1}
	    {InnerProc '#'(A1)}
	 end
      [] 2 then
	 proc {$ A1 A2}
	    {InnerProc A1#A2}
	 end
      [] 3 then
	 proc {$ A1 A2 A3}
	    {InnerProc A1#A2#A3}
	 end
      [] 4 then
	 proc {$ A1 A2 A3 A4}
	    {InnerProc A1#A2#A3#A4}
	 end
      [] 5 then
	 proc {$ A1 A2 A3 A4 A5}
	    {InnerProc A1#A2#A3#A4#A5}
	 end
      [] 6 then
	 proc {$ A1 A2 A3 A4 A5 A6}
	    {InnerProc A1#A2#A3#A4#A5#A6}
	 end
      [] 7 then
	 proc {$ A1 A2 A3 A4 A5 A6 A7}
	    {InnerProc A1#A2#A3#A4#A5#A6#A7}
	 end
      [] 8 then
	 proc {$ A1 A2 A3 A4 A5 A6 A7 A8}
	    {InnerProc A1#A2#A3#A4#A5#A6#A7#A8}
	 end
      else
	 {Error memoizer(type:illegalArity msg:'arity '#Ari#' not supported')}
	 unit
      end
   end

   proc {TupleCall P T}
      Ari = {ProcedureArity P}
   in
      case Ari
      of 1 then {P T.1}
      [] 2 then {P T.1 T.2}
      [] 3 then {P T.1 T.2 T.3}
      [] 4 then {P T.1 T.2 T.3 T.4}
      [] 5 then {P T.1 T.2 T.3 T.4 T.5}
      [] 6 then {P T.1 T.2 T.3 T.4 T.5 T.6}
      [] 7 then {P T.1 T.2 T.3 T.4 T.5 T.6 T.7}
      [] 8 then {P T.1 T.2 T.3 T.4 T.5 T.6 T.7 T.8}
      else
	 {Error memoizer(type:illegalArity msg:'arity '#Ari#' not supported')}
      end
   end
   
   fun {MkEvalIndexDef IndexDef FChange}
      fun {Eval IToArg Def}
	 case Def of app(F Sub) then
	    {{FChange F} {Eval IToArg Sub}}
	 [] ignore(IgnoredSub Sub) then
	    {Eval IToArg IgnoredSub _}
	    {Eval IToArg Sub}
	 elseif {IsInt Def} then
	    {IToArg Def}
	 else
	    {RecordMap Def fun {$ Sub} {Eval IToArg Sub} end}
	 end
      end
   in
      fun {$ IToArg} {Eval IToArg IndexDef} end
   end

   local
      proc {AssertIfPrecheckThenSingleOut Precheck NOuts}
	 if Precheck andthen NOuts \= 1 then
	    {Error memoizer(type:precheck msg:'precheck option requires a single return argument')}
	 end
      end
      local
	 proc {MatchRsltsAux VI AIs As V}
	    case AIs of AI|Rest then
	       V.VI = As.AI
	       {MatchRsltsAux VI+1 Rest As V}
	    else skip end
	 end
      in
	 proc {MatchRslts OutIs Args V} {MatchRsltsAux 1 OutIs Args V} end
      end
      proc {MatchRslt OutIs Args V} V = Args.(OutIs.1) end 
      %%
      fun {MkTuple W} {MakeTuple '#' W} end
      proc {DummyMkVal _ _} skip end
      %%
      fun {CollectInIs IndexDef}
	 InIs = {NewCell nil}
	 fun {IToArg I} Old in
	    Old = (InIs := I|Old)
	    I
	 end
      in
	 {{MkEvalIndexDef IndexDef {Const Id}} IToArg _}
	 @InIs
      end
      %%
      fun {CalcOutIs Ari InIs}
	 InS = {FS.value.make InIs}
	 AllS = {FS.value.make [1#Ari]}
	 OutS = {FS.diff AllS InS}
      in
	 {Wait OutS}
	 {FS.reflect.lowerBoundList OutS}
      end
      fun {MkBasicCore NOuts MkVal MatchVal}
	 proc {$ Lookup D K Proc Args OutIs} V in
	    if {Lookup D K $ V} then
	       {TupleCall Proc Args}
	       V = {MkVal NOuts}
	    end
	    {MatchVal OutIs Args V}
	 end
      end
      proc {PrecheckCore Lookup D K Proc Args OutIs}
	 OutI = OutIs.1
	 V = Args.OutI
	 V1
	 Args1 = {AdjoinAt Args OutI V1}
      in
	 {TupleCall Proc Args1}
	 case V1 of trivial(X) then V = X
	 elseif {Lookup D K $ V} then
	    V = {V1}
	 end
      end	 
   in
      fun {MkNewMemoizer Dict}
	 NewDict = Dict.new
	 Lookup = Dict.lookup
	 RemoveAll = Dict.removeAll
      in
	 fun {$ Proc IndexDef Precheck}
	    Ari = {ProcedureArity Proc}
	    D = {NewDict}
	    MkKey = {MkEvalIndexDef IndexDef Id}
	    InIs = {CollectInIs IndexDef}
	    OutIs = {CalcOutIs Ari InIs}
	    NOuts = {Length OutIs}
	    {AssertIfPrecheckThenSingleOut Precheck NOuts}
	    Core = if Precheck then PrecheckCore else
		      {MkBasicCore NOuts
		       if NOuts == 1 then DummyMkVal else MkTuple end
		       if NOuts == 1 then MatchRslt else MatchRslts end}
		   end
	    proc {Remember Args}
	       fun {IToArg I} Args.I end
	       K = {MkKey IToArg}
	    in
	       {Core Lookup D K Proc Args OutIs}
	    end
	    proc {Reset} {RemoveAll D} end
	 in
	    memo(
	       reset:Reset
	       proxy:{MkProxy Remember Proc})
	 end
      end
   end
   Dict = o(lookup:Lookup
	    new:Dictionary.new
	    removeAll:Dictionary.removeAll)
   fun {KeyChangeDict KeyChange}
      o(lookup:proc {$ D K IsNew V} {Lookup D {KeyChange K} IsNew V} end
	new:Dictionary.new
	removeAll:Dictionary.removeAll)
   end
end