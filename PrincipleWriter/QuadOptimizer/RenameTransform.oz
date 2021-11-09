%%
%%  Module: RenameTransform
%%
%%  Exports one PW tree transform that renames variables so that
%%  it is not possible anymore for a variable to override any other
%%  in scope. For most purposes, all happens as if all variable
%%  names are unique. Exceptions may happen between variables whose
%%  scopes do not intersect.
%%
%%  Obs.:
%%
%%  . argument variables (i.e. dimensions) are also renamed;
%%  . prefix "Usr" is added to all variable names; when this is
%%    not enough to avoid overriding, a unique number is inserted
%%    just after the prefix.
%%
functor
import
%   System(show)

   TopDown(asDl:AsDl
	   apply:Apply
	   'fail':Fail
	   ifMatched:IfMatched
	   ifMatchedElse:IfMatchedElse) at 'TopDownMatch.ozf'
   GornUtils(replace:Replace
	     condReplace:CondReplace) at 'GornUtils.ozf'
   Helpers(
      getSem:GetSem
      adjoinAtSem:AdjoinAtSem
      constantTree2A:ConstTree2A
      sem2A:Sem2A
      constantTreeIsVar:ConstantTreeIsVar) at 'MatchHelpers.ozf'
   PWTreeAccess(committed:MkAccess) at 'PWTreeAccess.ozf'
   Counter at 'x-oz://system/adt/Counter.ozf'
   %Ozcar(breakpoint:BP)
export
   The % : the transform
   MkVarReplace % : auxiliary function to build similar transforms. 
                %   Currently not used outside this module. 
prepare
   DropWhile = List.dropWhile
   V2A = VirtualString.toAtom
define
   fun {MkVarReplace NewVar Read}
      Pat
      o(match:Match goDown:GoDown mkEasy:MkEasy ...) = {MkAccess Pat}
      Easy2 = {MkEasy 2}
      !Pat = o(let:[Easy2 % Overlap not needed
		    Declare]
	       forall:Declare
	       exists:Declare
	       existsone:Declare
	       logicvar:ReadLogic
	       letdim:Declare
	       constant:ReadDom)

      fun {Declare Tbl Lbl Var X Form}
	 Tag = if Lbl == let then logic else dom end
	 VSem = {GetSem Var}
	 NewTbl#NewVSem = {NewVar Tbl Tag VSem}
	 FormDiff = {GoDown 3 NewTbl Form}
      in
	 {IfMatchedElse FormDiff Form
	  fun {$ FormDiff}
	     VarDiff = 1#[replace({AdjoinAtSem Var NewVSem})]
	  in
	     {AsDl [VarDiff FormDiff]}
	  end
	  Replace}
      end

      fun {Logicvar X} logicvar(X) end
      
      fun {ReadLogic Tbl _ Var}
	 Rslt = {Read Tbl logic Var}
      in
	 {CondReplace {IfMatched Rslt Logicvar}}
      end
     
      ReadDom = Apply(fun {$ Tbl ConstT}
			 if {ConstantTreeIsVar ConstT} then
			    {CondReplace {Read Tbl dom ConstT}}
			 else Fail end
		      end)
   in
      Match
   end
   
   %%
   %% The transform:
   %%
   local
      fun {NewVar UniqueVarId#Tbl Tag VSem}
	 VA = {Sem2A VSem}
	 NewVSem = constant({UniqueVarId Tbl Tag VSem})
	 Entry = Tag(VA NewVSem)
      in
	 (UniqueVarId#(Entry|Tbl))#NewVSem 
      end
	 
      fun {Read _#Tbl Tag VarConstT}
	 VA = {ConstTree2A VarConstT}
	 NewVSem = {Lookup Tbl Tag(VA $)}
      in
	 if NewVSem == unit then Fail else
	    {AdjoinAtSem VarConstT NewVSem}
	 end
      end

      proc {Lookup Tbl Rec}
	 Lbl = {Label Rec}
	 fun {DoesNotMatch Rec1}
	    {Label Rec1} \= Lbl orelse Rec1.1 \= Rec.1
	 end
      in
	 Rec.2 = case {DropWhile Tbl DoesNotMatch}
		 of nil then unit
		 [] L then L.1.2 end
      end

      Transform = {MkVarReplace NewVar Read}

      fun {MkUniqueVarId Prefix}
	 C = {Counter.new}
      in
	 fun {$ Tbl Tag VSem}
	    VA = {Sem2A VSem}
	    Unique = {IsUnit {Lookup Tbl Tag(VA $)}}
	    Infix = if Unique then nil else {C.next} end
	 in
	    {V2A Prefix#Infix#VA}
	 end
      end      
   in	 
      fun {The _ T}
	 X = {Transform {MkUniqueVarId 'Usr'}#nil T}
      in
	 X
      end
   end
end
