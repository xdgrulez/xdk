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

%% This class provides a simple log functionality.  It has four
%% logging levels:
%%
%%   0 = everything is logged
%%   1 = only errors and warnings are logged
%%   2 = only errors are logged
%%   3 = nothing is logged

functor
import
   Inspector
   System
export
   Log
   Logged
define
   class Log
      attr loggingLevel prefix
      meth init(Prefix)
	 %% per default, log errors and warnings
	 loggingLevel <- 1
	 prefix <- Prefix
      end
      meth setLoggingLevel(N)
	 loggingLevel <- N
      end
      meth log(Message)
	 if @loggingLevel =< 0 then
	    {Inspector.inspect "["#@prefix#"] "#Message}
	    {System.showError "["#@prefix#"] "#Message}
	 end
      end
      meth warn(Message)
	 if @loggingLevel =< 1 then
	    {Inspector.inspect "["#@prefix#"] WARNING: "#Message}
	    {System.showError "["#@prefix#"] WARNING: "#Message}
	 end
      end
      meth error(Message)
	 if @loggingLevel =< 2 then
	    {Inspector.inspect "["#@prefix#"] ERROR: "#Message}
	    {System.showError "["#@prefix#"] ERROR: "#Message}
	 end
      end
   end
   class Logged
      attr loggingLevel
      meth init
	 loggingLevel <- 1
      end
      meth setLoggingLevel(N)
	 loggingLevel <- N
      end
      meth log(Prefix Message)
	 if @loggingLevel =< 0 then
	    {System.showError "["#Prefix#"] "#Message}
	 end
      end
      meth warn(Prefix Message)
	 if @loggingLevel =< 1 then
	    {System.showError "["#Prefix#"] WARNING: "#Message}
	 end
      end
      meth error(Prefix Message)
	 if @loggingLevel =< 2 then
	    {System.showError "["#Prefix#"] ERROR: "#Message}
	 end
      end
   end
end
