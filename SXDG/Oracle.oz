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
   OracleProtocol at 'OracleProtocol.ozf'
export
   Oracle
define
   LogPrefix = "Oracle"
   class Oracle from OracleProtocol.oracleProtocol
      attr externaliser

      %% Initialisation
      meth init
	 OracleProtocol.oracleProtocol,init
	 {self log(LogPrefix "method call: init")}
      end

      %% Set the externaliser.
      meth setExternaliser(ExternaliserObject)
	 {self log(LogPrefix "method call: setExternaliser")}
	 externaliser <- ExternaliserObject
      end

      %% Call the respective methods of the externaliser.
      meth externaliseFull(Node $)
	 {self log(LogPrefix "method call: externaliseFull")}
	 {@externaliser externaliseFull({Node getSpace($)} $)}
      end
      meth externaliseDiff(OldNode NewNode $)
	 {self log(LogPrefix "method call: externaliseDiff")}
	 
	 OldSpace = {OldNode getSpace($)}
	 NewSpace = {NewNode getSpace($)}
      in
	 {@externaliser externaliseDiff(OldSpace NewSpace $)}
      end
   end
end
