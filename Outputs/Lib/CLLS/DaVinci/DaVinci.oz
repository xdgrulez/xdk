functor
import
   Counter(new) at 'x-ozlib://base/counter.ozf'
   Window(new)
   Configuration(parameter)
export
   Draw
   Close
define
   Memory = {Dictionary.new}
   
   fun {GetWindow}
      OldWindow = {Dictionary.condGet Memory window false}
   in
      case OldWindow of false then
	 {NewWindow}
      [] unit(daVinci:DaVinci ...) then
	 if {DaVinci.isDead} then
	    {NewWindow}
	 else
	    OldWindow
	 end
      end
   end

   fun {NewWindow}
      NewWindow = {Window.new Configuration.parameter} /*** ACHTUNG ***/
   in
      Memory.window := NewWindow
      NewWindow
   end

   proc {Close}
      OldWindow = {GetWindow}
   in
      case OldWindow of false then
	 skip
      [] unit(daVinci:OldDaVinci ...) then
	 if {OldDaVinci.isDead} then
	    skip
	 else
	    {OldDaVinci.close}
	 end
%	 {OldWindow.closeHistory}
      end
   end
   
   proc {Draw Constr} 
      Window = {GetWindow}
   in
      {Window.draw Constr}
   end
end
