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
   Oracle at 'Oracle.ozf'
export
   oracle: GlobalOracle
define
   LogPrefix = "GlobalOracle"
   class GlobalOracle from Oracle.oracle
      %% Initialisation
      meth init
	 Oracle.oracle,init
	 {self log(LogPrefix "method call: init")}
      end

      %% Inform the oracle that a new root node has been created.
      %% Return true if the message was confirmed by the oracle;
      %% otherwise, return false.
      meth newRoot(Root $)
	 {self log(LogPrefix "method call: newRoot")}
	 
	 Id = {Root getId($)}
	 Description = Oracle.oracle,externaliseFull(Root $)
      in
	 Oracle.oracle,messageReset($) andthen
	 Oracle.oracle,messageNew(Id Id Description $)
      end

      %% Inform the oracle that a new inner node has been created.
      %% Return true if the message was confirmed by the oracle;
      %% otherwise, return false.
      meth newNode(Node $)
	 {self log(LogPrefix "method call: newNode")}
	 
	 NodeId = {Node getId($)}
	 Parent = Node.mom
	 ParentId = {Parent getId($)}
	 NodeDescription = Oracle.oracle,externaliseDiff(Node Parent $)
      in
	 Oracle.oracle,messageNew(NodeId ParentId NodeDescription $)
      end

      %% Ask the oracle about the Id of the node at which to continue
      %% search, and return this Id (a value of type key) if the
      %% oracle could answer this question; otherwise, return false.
      meth getNextNodeId($)
	 {self log(LogPrefix "method call: getNextNodeId")}
	 Oracle.oracle,messageNextGlobal($)
      end
   end
end
