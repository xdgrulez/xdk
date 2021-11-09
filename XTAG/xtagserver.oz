%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
   Application(getArgs exit)
   System(showError)
   
   SocketProvider(provide) at 'SocketProvider.ozf'
define
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)
	   port(single type:int char:&p default:4712)
	   prune(single type:bool char:&r default:true)
	   filter(single type:string char:&f default:"none"))}
   %%
   if AArgRec.help then
      {System.showError
       '--(no)help                   display this help\n'#
       ' -h\n'#
       '--port <Int>                 grammar generator port\n'#
       ' -p                          (e.g. --port 42\n'#
       '                              default 4712)\n'#
       '--(no)prune                  prune tree lookup\n'#
       ' -r                          (default: prune)\n'#
       '--filter none|simple|tagger|\n'#
       '         supertagger         select tree deletion filter\n'#
       ' -f                          (e.g. --filter simple\n'#
       '                              default none)\n'}


      {Application.exit 0}
   end
   %% port
   PortI = AArgRec.port
   %% prune
   PruneB = AArgRec.prune
   %% filter
   FilterS = AArgRec.filter
   FilterA =
   case FilterS
   of "simple" then simple
   [] "tagger" then tagger
   [] "supertagger" then supertagger
   else none
   end
   %%
   {SocketProvider.provide o(port: PortI
			     prune: PruneB
			     filter: FilterA)}
end

