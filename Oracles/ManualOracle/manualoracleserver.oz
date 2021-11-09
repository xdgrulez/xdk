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
   
   ManualOracle at 'ManualOracle.ozf'
define
   AArgRec =
   {Application.getArgs
    record(help(single type:bool char:&h default:false)

	   port(single type:int char:&p default:4711))}
   %%
   if AArgRec.help then
      {System.showError
       '--(no)help                   display this help\n'#
       ' -h\n'#
       '--port <Int>                 oracle port\n'#
       ' -p                          (e.g. --port 42, default 4711)\n'
      }
      {Application.exit 0}
   end
   %%
   PortI = AArgRec.port
   %%
   {ManualOracle.init o(port: PortI)}
end
