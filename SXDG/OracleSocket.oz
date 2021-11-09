%%
%% Author:
%%   Marco Kuhlmann <kuhlmann@ps.uni-sb.de>
%%
%% Copyright:
%%   Marco Kuhlmann, 2004
%%
%% Last Change:
%%   $Date: 2017/04/06 12:47:24 $ by $Author: osboxes $
%%   $Revision: 1.3 $
%%

%% This functor contains the OracleSocket class, which provides the
%% low-level methods for communicating with an external oracle.

functor
import
   Open
   Log(logged) at 'Log.ozf'
export
   OracleSocket
define
   LogPrefix = "OracleSocket"
   class OracleSocket from Open.socket Open.text Log.logged
      %% Initialisation
      meth init
	 Log.logged,init
	 {self log(LogPrefix "method call: init")}
	 Open.socket,init
      end

      %% Connect to host Host at port Port.
      meth connect(Host Port)
	 {self log(LogPrefix "method call: connect")}
	 {self log(LogPrefix "connecting to host "#Host#" at port "#Port)}
	 Open.socket,connect(host:Host port:Port)
	 {self log(LogPrefix "connection established")}
      end

      %% Close the connection.
      meth close
	 {self log(LogPrefix "method call: close")}
	 {self log(LogPrefix "closing connection")}
	 Open.socket,flush
	 Open.socket,close
	 {self log(LogPrefix "connection closed")}
      end

      %% Use the active connection to send a Message.
      meth send(Message)
	 {self log(LogPrefix "method call: send")}
	 Open.text,putS(Message)
	 {self log(LogPrefix "message sent: "#Message)}
      end

      %% use the active connection to receive a reply
      meth receive($)
	 {self log(LogPrefix "method call: receive")}
	 case Open.text,getS($)
	 of false then
	    {self log(LogPrefix "received EOF")}
	    false
	 [] Chars then
	    {self log(LogPrefix "message received: "#Chars)}
	    Chars
	 end
      end

      %% combined send and receive
      meth query(Message Reply)
	 {self log(LogPrefix "method call: query")}
	 OracleSocket,send(Message)
	 OracleSocket,receive(Reply)
      end
   end
end
