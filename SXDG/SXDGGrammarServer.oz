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

%% This functor provides the interface to Peter's grammar server.

functor
import
   Open
   Helpers at 'Helpers.ozf'
   Log at 'Log.ozf'
export
   grammarServer: SXDGGrammarServer
define
   LogPrefix = "SXDGGrammarServer"
   class SXDGGrammarServer from Open.socket Open.text Log.logged
      %% Initialisation
      meth init
	 Log.logged,init
	 Open.socket,init
      end

      %% Connect to host Host at port Port.
      meth connect(Host Port)
	 {self log(LogPrefix "connecting to host "#Host#" at port "#Port)}
	 Open.socket,connect(host:Host port:Port)
	 {self log(LogPrefix "connection established")}
      end

      %% Close the connection.  This method is currently not supported
      %% by Peter's server, which is rather bad.
      meth close
	 {self log(LogPrefix "closing the connection")}
	 Open.socket,close
	 {self log(LogPrefix "connection closed")}
      end

      %% Low-level functionality to send a message and receive a reply
      %% from the remote grammar server.
      meth Send(Message)
	 Open.text,putS(Message)
	 {self log(LogPrefix "message sent: "#Message)}
      end
      meth Receive($)
	 case Open.text,getS($)
	 of false then
	    {self log(LogPrefix "received EOF")}
	    false
	 [] Chars then
	    fun {Read Acc}
	       case Open.text,getS($)
	       of false then
		  {self log(LogPrefix "received EOF")}
		  {List.reverse Acc}
	       [] Chars then
		  if Chars == "" then
		     {self log(LogPrefix "received empty line")}
		     {List.reverse Acc}
		  else
		     {self log(LogPrefix "received line: "#Chars)}
		     {Read Chars|Acc}
		  end
	       end
	    end
	 in
	    {self log(LogPrefix "received line: "#Chars)}
	    {Read [Chars]}
	 end
      end
      meth Query(Message Reply)
	 SXDGGrammarServer,Send(Message)
	 SXDGGrammarServer,Receive(Reply)
      end

      %% Given a list of Words (atoms, strings, or virtual strings),
      %% return a textual description of an XDG grammar in the user
      %% language.  This can then be used (by the functions provided
      %% through XDG's Compiler functor) to compile an actual grammar.
      meth getGrammar(Words GrammarString)
	 Sentence = {Helpers.string.concatWith " " Words}
	 GrammarLines % the grammar server's reply
      in
	 {self log(LogPrefix "requesting a grammar for: "#Sentence)}
	 SXDGGrammarServer,Query(Sentence GrammarLines)
	 {Helpers.string.concatWith "\n" GrammarLines GrammarString}
	 {self log(LogPrefix "grammar received")}
      end
   end
end
