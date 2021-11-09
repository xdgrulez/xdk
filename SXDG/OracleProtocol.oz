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

%% This functor implements the oracle protocol.

functor
import
   Helpers at 'Helpers.ozf'
   MessageParser at 'MessageParser.ozf'
   OracleSocket at 'OracleSocket.ozf'
export
   OracleProtocol
define
   LogPrefix = "OracleProtocol"
   fun {ProtocolError X} oracleProtocolError(message:X) end
   class OracleProtocol from OracleSocket.oracleSocket
      attr messageParser

      %% Initialisation
      meth init
	 OracleSocket.oracleSocket,init
	 messageParser <- {New MessageParser.messageParser init}
      end

      %% Send the message M (an Helpers.xml.element) and return true
      %% if it was confirmed by the oracle; otherwise, return false.
      meth ConfirmMessage(M $)
	 Reply
      in
	 {self log(LogPrefix "confirming message")}
	 OracleSocket.oracleSocket,query({M toString($)} Reply)
	 if Reply == false then
	    {self warn(LogPrefix "oracle replied with EOF")}
	    false
	 else
	    {self log(LogPrefix "raw reply: "#Reply)}
	    case {@messageParser parseVS(Reply $)}
	    of [element(name:confirm attributes:nil children:nil)] then
	       {self log(LogPrefix "message confirmed")}
	       true
	    [] [element(name:reject attributes:nil children:nil)] then
	       {self warn(LogPrefix "message rejected")}
	       false
	    [] X then raise {ProtocolError X} end
	    end
	 end
      end

      meth messageEvaluate(Id $)
	 M = {New Helpers.xml.element init("evaluate")}
	 R % the oracle's reply
      in
	 {M addAttribute("id" Id)} %% TODO: should be refid
	 {self log(LogPrefix "messageEvaluate: "#{M toString($)})}
	 OracleSocket.oracleSocket,query({M toString($)} R)
	 case {@messageParser parseVS(R $)}
	 of [element(name:evaluated attributes:Attributes children:nil)] then
	    case Attributes
	    of [attribute(name:value value:Value)] then
	       {self log(LogPrefix "oracle replied: node #"#Id#"="#Value)}
	       {String.toFloat {VirtualString.toString Value}}
	    [] X then raise {ProtocolError X} end
	    end
	 [] X then raise {ProtocolError X} end
	 end
      end
      
      %% Send the init message and return true if the message was
      %% confirmed by the oracle; otherwise, return false.  Note that
      %% this does not really do anything interesting currently.  In
      %% later versions of the protocol, the init dialogue should
      %% negotiate a set of features that may be used during the
      %% communication.  It also should confirm that the oracle
      %% understands the language used for the externalisation.
      meth messageInit($)
	 M = {New Helpers.xml.element init("init")}
      in
	 {self log(LogPrefix "messageInit: "#{M toString($)})}
	 OracleProtocol,ConfirmMessage(M $)
      end

      %% Send the reset message and return true if the message was
      %% confirmed by the oracle; otherwise, return false.
      meth messageReset($)
	 M = {New Helpers.xml.element init("reset")}
      in
	 {self log(LogPrefix "messageReset: "#{M toString($)})}
	 OracleProtocol,ConfirmMessage(M $)
      end

      %% Inform the oracle that a new search node (with id Id, an
      %% integer) has been created whose parent node has id ParentId
      %% (also an integer) and whose externalisation is given by the
      %% XML element Description.  Return true if the oracle confirms
      %% the message; otherwise, return false.
      meth messageNew(Id ParentId Description $)
	 M = {New Helpers.xml.element init("new")}
      in
	 {M addAttribute("id" Id)}
	 {M addAttribute("parentid" ParentId)}
	 {M addChildString(Description)}
	 {self log(LogPrefix "messageNew: "#{M toString($)})}
	 OracleProtocol,ConfirmMessage(M $)
      end

      %% Ask the oracle where to continue the search, given that the
      %% current search node has id Id.  Return the id of the new
      %% search node (an integer), or false, if the oracle's reply
      %% could not be interpreted.
      meth messageNextLocal(Id $)
	 M = {New Helpers.xml.element init("chooseLocal")}
	 R % the oracle's reply
      in
	 {M addAttribute("refid" Id)}
	 {self log(LogPrefix "messageNextLocal: "#{M toString($)})}
	 OracleSocket.oracleSocket,query({M toString($)} R)
	 case {@messageParser parseVS(R $)}
	 of [element(name:next attributes:Attributes children:nil)] then
	    case Attributes
	    of [attribute(name:id value:Next)] then
	       {self log(LogPrefix "oracle replied: continue with node #"#Next)}
	       {String.toInt {VirtualString.toString Next}}
	    [] X then raise {ProtocolError X} end
	    end
	 [] [element(name:noUnexpandedState attributes:nil children:nil)] then
	    {self warn(LogPrefix "oracle replied: no unexpanded state")}
	    false
	 [] X then raise {ProtocolError X} end
	 end
      end

      %% Ask the oracle where to continue the search.  Return the id
      %% of the new search node (an integer), or false, if the
      %% oracle's reply could not be interpreted.
      meth messageNextGlobal($)
	 M = {New Helpers.xml.element init("chooseGlobal")}
	 R % the oracle's reply
      in
	 {self log(LogPrefix "messageNextGlobal: "#{M toString($)})}
	 OracleSocket.oracleSocket,query({M toString($)} R)
	 case {@messageParser parseVS(R $)}
	 of [element(name:next attributes:Attributes children:nil)] then
	    case Attributes
	    of [attribute(name:id value:Next)] then
	       {self log(LogPrefix "oracle replied: continue with node #"#Next)}
	       {String.toInt {VirtualString.toString Next}}
	    [] X then raise {ProtocolError X} end
	    end
	 [] [element(name:noUnexpandedState attributes:nil children:nil)] then
	    {self warn("oracle replied: no unexpanded state")}
	    false
	 [] X then raise {ProtocolError X} end
	 end
      end
   end
end
