%%
%%  Module LazyList
%%
%%  Exports common lazy list procedures. Used by module TopDownMatch. 
%%
functor
export
   Map
   MapTail
define
   %%
   %% MapTail: Xs -> T -> F -> Ys - similar to the usual Map predicate
   %% but forthe fact that the resulting list - Ys - will have T as tail.
   fun lazy {MapTail Xs T F}
      case Xs of nil then T
      [] Y|Ys then {F Y}|{MapTail Ys T F}
      end
   end
   fun {Map Xs F}
      {MapTail Xs nil F}
   end
end