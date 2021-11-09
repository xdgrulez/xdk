%%
%% Author:
%%   Marco Kuhlmann <kuhlmann@ps.uni-sb.de>
%%
%% Copyright:
%%   Marco Kuhlmann, 2004
%%
%% Last Change:
%%   $Date: 2017/04/06 12:47:23 $ by $Author: osboxes $
%%   $Revision: 1.3 $
%%

functor
import
   Space
   Log(logged) at 'Log.ozf'
export
   BruteForceSearchClass
define
   LogPrefix = "BruteForceSearch"
   
   class BruteForceSearchClass from Log.logged
      attr failures maxDepth solutions spaces timedOut timeout

      %% initialisation
      meth init
	 Log.logged,init
	 {self log(LogPrefix "method call: init")}
      end
      
      %% depth-first exploration
      meth DFE(S Depth)
	 {self log(LogPrefix "method call: DFE (depth "#Depth#" )")}
	 {self log(LogPrefix "timeout in "#@timeout-{Time.time}#" seconds")}
	 if {Time.time} < @timeout then
	    spaces <- @spaces + 1
	    maxDepth <- {Max @maxDepth Depth}
	    case {Space.ask S}
	    of failed then
	       {self log(LogPrefix "DFE: failure")}
	       failures <- @failures + 1
	    [] succeeded then
	       {self log(LogPrefix "DFE: solution")}
	       solutions <- @solutions + 1
	    [] alternatives(2) then
	       {self log(LogPrefix "DFE: branch")}
	       C = {Space.clone S}
	    in
	       {Space.commit S 1} BruteForceSearchClass,DFE(S Depth+1)
	       {Space.commit C 2} BruteForceSearchClass,DFE(C Depth+1)
	    end
	 else
	    {self log(LogPrefix "timeout")}
	    timedOut <- true
	 end
      end

      meth search(Script Timeout Solutions Stats)
	 failures <- 0
	 maxDepth <- 0
	 solutions <- 0
	 spaces <- 0
	 timedOut <- false
	 timeout <- {Time.time} + Timeout
	 
	 %% Do the search.
	 BruteForceSearchClass,DFE({Space.new Script} 0)
	 
	 %% Return statistics even if the search timed out.
	 Stats =
	 [failures#@failures
	  maxDepth#@maxDepth
	  solutions#@solutions
	  spaces#@spaces]

	 %% If the search did not time out, return the empty list of
	 %% solutions.
	 if {Not @timedOut} then Solutions = nil end
      end
   end

end
