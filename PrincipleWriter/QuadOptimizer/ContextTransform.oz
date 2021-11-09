%%
%%  Module ContextTransform
%%
%%  Exports one single transform that adds context information
%%  for each expression in a tree.
%%
functor
import
%   System(show)

   TopDown('else':Else
	   easy:TdEasy
	   just:Just
	   apply:Apply
	   'fail':Fail
	   mkIf:MkIf
	   mkSimpleMatch:MkMatch
	   final:Final
	   asDl:AsDl) at 'TopDownMatch.ozf'
   MatchHelpers(
      samePat:SamePat
      getSem:GetSem
      gornAdjoin:GornAdjoin
      constantTree2A:ConstTree2A) at 'MatchHelpers.ozf'
   GornUtils(make) at 'GornUtils.ozf'
   FindVar(collect:CollectVars) at 'FindVar.ozf'
%   Ozcar(breakpoint:BP)
export
   The % : the transform
prepare
   DropWhile = List.dropWhile
define

   Constant = [entry attrs constant
	       mothers daughters up down
	       mothersL daughtersL upEndL downL
	       equp eqdown]
   
   local
      Unit = Just(unit)
      Pat = {Adjoin o(anno:TdEasy(Pat))
	     {SamePat Constant Unit}}
      Match = {MkMatch Pat}
   in
      fun {NotConstant T}
	 {Final {Match T}} == nil
      end
   end
		
   local
      o(easy:Easy1 mkEasy:MkEasy
	eitherWay:EitherWay doChildrenPat:DoChildrenPat
	match:Match ...) = {GornUtils.make Pat}
      Easy2 = {MkEasy 2}
      Easy3 = {MkEasy 3}
      Pat = {Adjoin
	     {SamePat Constant Fail}
	     o(s:Easy2
	       defprinciple:Easy3
	       constraints:Easy1
	       '|':EitherWay
	       %%
	       letdim:AddLettrace
	       exists:Q
	       existsone:Q
	       forall:Q
	       setExists:Q
	       setExistsOne:Q
	       setForall:Q
	       anno:[Easy1
		     {MkIf NotConstant AddSrcvar}]
	       Else:[DoChildrenPat
		     AddSrcvar])}
      AddLettrace
      = Apply(fun {$ VAs T}
		 Sem = {GetSem T}
		 FormI = {Width Sem}
		 Form = Sem.FormI
		 VA = {ConstTree2A Sem.1}
		 NewForm = {GornAdjoin Form {Final {Match VA|VAs Form}}}
		 NewSem = {AdjoinAt Sem FormI lettrace(VA  NewForm)}
	      in
		 replace(NewSem)
	      end)
      AddSrcvar
      = Apply(fun {$ VAs T}
		 AppliedVars = {CollectVars T}
		 Context = {DropWhile VAs
			    fun {$ VA} {Not {Member VA AppliedVars}} end}
	      in
		 if Context == nil then Fail else
		    MyV = Context.1
		    Required = MyV \= VAs.1
		    Nested
		 in
		    {AsDl [unify(Nested) replace(srcvar(MyV Nested Required))]}
		 end
	      end)
      Q = [AddLettrace
	   AddSrcvar]
   in
      fun {The _ T} {Match nil T} end
   end
end
