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
   oracle: LocalOracle
define
   LogPrefix = "LocalOracle"
   class LocalOracle from Oracle.oracle
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
	 Parent = {Node getParent($)}
	 ParentId = {Parent getId($)}
	 NodeDescription = Oracle.oracle,externaliseDiff(Parent Node $)
      in
	 Oracle.oracle,messageNew(NodeId ParentId NodeDescription $)
      end

      %% Given a search node Parent, ask the oracle about the Id of a
      %% child of Parent at which to continue search, and return this
      %% Id (a value of type key) if the oracle could answer this
      %% question; otherwise, return false.
      meth getNextChildId(Parent $)
	 {self log(LogPrefix "method call: getNextChildId")}
	 Oracle.oracle,messageNextLocal({Parent getId($)} $)
      end
   end
end
