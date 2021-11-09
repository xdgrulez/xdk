%%
%%  Module MkTransform
%%
%%  Exports transform builders taking a simple reduce as a parameter.
%%  In other words, a builder takes a function mapping a tree into
%%  another tree (returned as a singleton list, if succeeded, or as
%%  nil, otherwise) and returns a transform, which tries to apply
%%  the given function everywhere in a tree.
%%
%%  Transforms came in three flavours, namely:
%%  . basic: proceeds in a top-down manner and, once the reduce
%%    succeeds for a subtree, the subtrees of the result are not further
%%    traversed. It is most efficient but not usually applicable;
%%  . saturate.topDown: proceeds in a top-down manner and, if the
%%    reduce succeeds, the subtrees of the result themselves are
%%    traversed for further reduces;
%%  . saturate.bottomUp: proceeds in a bottom-up manner, i.e. lower
%%    subtrees are transformed first and higher ones are processed
%%    after incorporating the changes to their subtrees.
%%
%%  Usage notes:
%%  . this module is specific to PW trees and will only reach
%%    subtrees accessible through module PWTreeAccess. This is so
%%    for efficiency reasons. Full genericity can be achieved by
%%    means of mkTransf exported by module GornUtils or other of
%%    these utils;
%%  . the reduce parameter: again for efficiency reasons,
%%    what a transform builder receives as a parameter is not a
%%    reduce function proper, but a reduce function "index" - i.e.
%%    a record of such functions indexed by the root label of the trees
%%    they are applicable to.
%%
functor
import
   Gorn(mkSaturateTopDown:MkSaturateTopDown
	mkSaturateBottomUp:MkSaturateBottomUp
	mkReplace:MkReplace) at 'GornUtils.ozf'
   PWTreeAccess(committed:MkAccess) at 'PWTreeAccess.ozf'
export
   saturate:Saturate
   Basic
prepare
   RecordMap = Record.map
define

   %%
   %% Make: Fs -> PrepareF -> Transform - takes a reduce function
   %% index and creates all flavours of transforms. What changes is
   %% PrepareF, which turns functions into patterns.
   %%
   fun {Make Fs PrepareF}
      PreparedFs
      o(match:Match
	doChildren:DoChildren ...) = {MkAccess PreparedFs}
   in
      PreparedFs = {RecordMap Fs {PrepareF DoChildren}}
      Match
   end
   
   fun {SatTopDown Reduces}
      {Make Reduces MkSaturateTopDown}
   end
   fun {SatBottomUp Reduces}
      {Make Reduces MkSaturateBottomUp}
   end
   
   Saturate = o(topDown:SatTopDown
		bottomUp:SatBottomUp)

   fun {Basic Fs}
      {Make Fs MkReplace}
   end
end
