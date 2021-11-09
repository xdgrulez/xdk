%%
%%  Module QuadOptimizer
%%
%%  This module exports one function that returns the tree obtained
%%  by applying all quad optimization transforms to a given PW
%%  semantic tree
%%  
functor
import
   TopDownMatch(final:Final) at 'TopDownMatch.ozf'
   RenameTransf at 'RenameTransform.ozf'
   LetTransf at 'LetTransform.ozf'
   ContextTransf at 'ContextTransform.ozf'
   QuadTransf at 'QuadTransform.ozf'
   TrivialTransfs at 'TrivialTransforms.ozf'
   ZeroOrOneTransf at 'ZeroOrOneTransform.ozf'
   ToSemTreeTransf at 'ToSemTreeTransform.ozf'
   AdhocTransf at 'AdhocTransforms.ozf'
%   Browser(object browse:Browse)
   MatchHelpers(gornAdjoin:GornAdjoin
%		semsOnly:SemsOnly
		constantTree2A:ConstTree2A
		getSemLabel:SemLbl) at 'MatchHelpers.ozf'
   Helpers(mkNewAtom:MkNewAtom) at 'Helpers.ozf'
   FindVar(spurious:SpuriousVar) at 'FindVar.ozf'
%   Open
   Counter(newFromInt:NewCounter) at 'x-oz://system/adt/Counter.ozf'
   System(showInfo:ShowInfo
	  showError:ShowError)
%   Ozcar(breakpoint:BP)
%   Application
export
   Optimize
   Options
   Help
prepare
   V2VS = Value.toVirtualString
   VS2S = VirtualString.toString
   Drop = List.drop
   DropWhile = List.dropWhile
   IsDigit = Char.isDigit
define
   Options
   = ['allow-seon'(single type:bool default:false)
      adhoc(single type:bool default:true)
     ]

   proc {Help}
      {ShowError
       '--(no)allow-seon     allows generating setExistsOneNodes\n'#
       '                     (default: noallow-seon)\n'#
       '--(no)adhoc          allows applying adhoc transforms\n'#
       '                     (default: adhoc)\n'
      }
   end
   
%    local
%       F = {New class $ from Open.file Open.text end init(name:stdin)}
%    in
%       proc {Pause} {F getC(_)} end
%    end

%    {Browser.object option(display depth:100 width:2000)}
%    fun {BrowseTransf _ T}
%       {Browse {SemsOnly T}}
%       {Pause}
%       nil
%    end
   
%    fun {AddBP Transf}
%       fun {$ Arg T}
% 	 {BP}
% 	 {Transf Arg T}
%       end
%    end
%    fun {ExitTransf _ _}
%       {Application.exit 1}
%       nil
%    end
  
   Transfs
   = [ RenameTransf.the
       o(arg:constTrue f:LetTransf.irreversible.the)
       o(arg:skipAdhoc f:AdhocTransf.the)
       o(arg:quad f:QuadTransf.the)
       TrivialTransfs.zero
       ZeroOrOneTransf.the
       TrivialTransfs.'false'
       TrivialTransfs.memo
       TrivialTransfs.impl
       ContextTransf.the
       o(arg:newVarId f:LetTransf.restore.the)
       o(arg:spurious f:LetTransf.irreversible.the)
       o(arg:countAutos f:LetTransf.irreversible.the)
       ToSemTreeTransf.the
       %BrowseTransf
     ]

   Skip = {NewName}
   
   fun {MkApplyTransf Arg0}
      fun {$ Tree Transf0}
	 Arg#Transf = if {IsProcedure Transf0} then unit#Transf0
		      else Arg0.(Transf0.arg)#Transf0.f end
      in
	 if Arg == Skip then Tree else
	    Diff = {Final {Transf Arg Tree}}
	 in
	    {GornAdjoin Tree Diff}
	 end
      end
   end
   
   proc {Optimize Tree Options OptTree}
      CheckNestedQ = if Options.'allow-seon'
		     then AnyNestedQ else NotExistsOneNodes end
      SkipAdhoc = if Options.'adhoc' then unit else Skip end
      AutoCounter = {NewCounter 0}
      Arg = o(quad:
		 o(report:ReportQuadReduce
		   checkNestedQ:CheckNestedQ)
	      newVarId:{MkNewAtom 'Auto' 1}
	      constTrue:fun {$ _ _} true end
	      spurious:SpuriousVar
	      countAutos:fun {$ _ _} {AutoCounter.next _} false end
	      skipAdhoc:SkipAdhoc)
      NAutos
   in
      OptTree = {FoldL Transfs {MkApplyTransf Arg} Tree}
      NAutos = {AutoCounter.get}
      if NAutos \= 0 then
	 {ShowInfo 'CSE: '#NAutos#' automatic variable(s) created.'}
      end
   end

   fun {AnyNestedQ _ _} true end

   fun {NotExistsOneNodes Q Dom}
      Q \= existsone orelse {SemLbl Dom} \= node
   end

   local
      fun {Unmangle VarVS}
	 DropUsr = {Drop {VS2S VarVS} 3}
      in
	 {DropWhile DropUsr IsDigit}
      end
   in
      proc {ReportQuadReduce VarTree}
	 {ShowInfo 'quad reduce: variable '#{Unmangle {ConstTree2A VarTree}}
	  #' at '#{V2VS VarTree.coord 2 2}#' eliminated'}
      end
   end
end
       
       
       
	      