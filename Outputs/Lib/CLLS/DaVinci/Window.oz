functor
import
   Interface(new)       at 'x-ozlib://niehren/davinci/manager.ozf'
%   Rclls(new)           at 'x-ozlib://chorus/clls/rclls.ozf'
%   History(add close)   at 'history.ozf'
%   Config(parameter)
%   DaVinciCLLS(toGraph) at 'clls.ozf'
   LayoutParameter(parameter)
export 
   new:New
define
   fun{New Opts}
      DaVinci = thread
		   DaVinci = {Interface.new Parameter}
		in
		   {DaVinci.setSize Opts.size}
		   {DaVinci.setTitle Opts.title}
		   DaVinci
		end
      
      Parameter= unit(layout       : LayoutParameter.parameter
		      configuration: ['set(font_size(10))'
				      'set(gap_width(4))'
				      'set(gap_height(12))'
				      'set(layout_accuracy(5))'
				      'set(keep_nodes_at_levels(false))'
				     ]
		     )
      
      proc {Draw CLLS}
%	 RCLLS = if {Value.hasFeature CLLS clls} then
%		    CLLS
%		 else
%		    {Rclls.new CLLS unit}
%		 end

	 /* HIER */
%	 DVGraph = {DaVinciCLLS.toGraph CLLS}	 
%      in

%	 {History.add RCLLS}
%	 {DaVinci.value.set CLLS}
	 {DaVinci.newGraph /*DVGraph*/CLLS}
      end
   in
      unit(draw:Draw daVinci:DaVinci)
   end
end
