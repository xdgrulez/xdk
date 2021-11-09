functor
import
   System(show)
   
   Share(apply) at 'Share.ozf'
export
   Fd
   Fs
   IndexedUnion
   Inter
   SeqSelect
   SeqUnion
   The
   Union
define
   proc {Fd Arg1 Arg2 Arg3} {Share.apply 'Select' [fd] [Arg1#vec(fd) Arg2#fd Arg3#fd]} end
   proc {Fs Arg1 Arg2 Arg3} {Share.apply 'Select' [fs] [Arg1#vec(fs) Arg2#fd Arg3#fs]} end
   proc {IndexedUnion Arg1 Arg2 Arg3} {Share.apply 'Select' [indexedUnion] [Arg1#list(vec(fs)) Arg2#fs Arg3#fs]} end
   proc {Inter Arg1 Arg2 Arg3} {Share.apply 'Select' [inter] [Arg1#vec(fs) Arg2#fs Arg3#fs]} end
   proc {SeqSelect Arg1 Arg2} {Share.apply 'Select' [seqSelect] [Arg1 Arg2]} end % not documented in MOGUL select 1.8
   proc {SeqUnion Arg1 Arg2} {Share.apply 'Select' [seqUnion] [Arg1#vec(fs) Arg2#fs]} end
   proc {The Arg1 Arg2} {Share.apply 'Select' [the] [Arg1#fs Arg2#fd]} end % not documented in MOGUL select 1.8
   proc {Union Arg1 Arg2 Arg3} {Share.apply 'Select' [union] [Arg1#vec(fs) Arg2#fs Arg3#fs]} end
end
