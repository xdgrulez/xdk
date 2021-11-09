%%
%%  Module: ToSemTreeTransform
%%
%%  When a transform creates new nodes, it usually cares about and
%%  inserts purely semantic information, i.e. it does not create
%%  usual "value" nodes (which contain "coord", "file", and "sem"
%%  fields), only what should go in their "sem" fields. This module
%%  exports one transform that corrects this so as to turn an
%%  optimized tree into a standard semantic tree. The basic idea
%%  is that every "valueless" semantic node will inherit attributes
%%  coord and file from its nearest ancestor whose attributes have
%%  been left untouched by optimization.
%%
functor
import
%   System(show)

   MatchTopDown('fail':Fail
		'else':Else
		final:Final
		apply:Apply) at 'TopDownMatch.ozf'
   GornUtils at 'GornUtils.ozf'
   MatchHelpers(gornAdjoin:GornAdjoin
		adjoinAtSem:AdjoinAtSem) at 'MatchHelpers.ozf' 
export
   The
define

   o(match:Match doChildren:DoChildren eitherWay:EitherWay ...)
   = {GornUtils.make Pat}

   Pat = o('|':EitherWay
	   nil:Fail
	   Else:
	      [Apply(fun {$ _ T}
			if {HasFeature T sem}
			then {DoChildren T T} else Fail end
		     end)
	       Apply(fun {$ T1 T2}
			if {HasFeature T2 sem} then
			   Fail
			else Diff = {Final {DoChildren T1 T2}} in
			   replace({AdjoinAtSem T1 {GornAdjoin T2 Diff}})
			end
		     end)
	      ]
	 )

   fun {The _ T}
      {Match value(coord:unit file:unit sem:unit) T}
   end
end