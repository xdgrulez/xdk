functor
import
   FS at 'FS.ozf'
   FD at 'FD.ozf'
   PW at 'PW.base.ozf'
   Prechk(decheckOn:DecheckOn) at 'PW.prechecked.ozf'
export
   New
   Prepare
   Option
   Abstract
define

   Option = none
   Abstract = Option
   
   fun {Prepare G}
      unit
   end
   
   Kit = 'export'(
	    fd:FD
	    fs:FS
	    pw:PW)
  
   fun {New _ _}
      {DecheckOn}
      Kit
   end
end