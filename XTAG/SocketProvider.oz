%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
%   System(show)
   
   Helpers(fillRec serverK) at 'Helpers.ozf'

   GrammarGenerator(generate) at 'GrammarGenerator.ozf'
export
   Provide
define
   S2A = String.toAtom
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% default options
   %%
   DefaultOptRec =
   o(port: 4712
     prune: true
     filter: none)
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% global variables
   %%
   GlobalDict = {NewDictionary}
   %% server object
   GlobalDict.serverO := unit
   %% options
   GlobalDict.optRec := unit
   %%
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% exported procedures
   %%
   %% Provide: OptRec -> U
   %% Provides a grammar generator socket.
   proc {Provide OptRec1}
      OptRec = {Helpers.fillRec OptRec1 DefaultOptRec}
      GlobalDict.optRec := OptRec
   in
      thread {MainLoop} end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% the server main loop
   %%
   %% MainLoop: U -> U
   proc {MainLoop}
      ServerO = {New Helpers.serverK init}
      GlobalDict.serverO := ServerO
      OptRec = GlobalDict.optRec
      %%
      PortI = OptRec.port
      PruneB = OptRec.prune
      FilterA = OptRec.filter
      %%
      {ServerO bind(takePort:PortI)}
      {ServerO listen}
      {ServerO accept}
      SentenceS = {ServerO getS($)}
%      {Inspector.inspect {String.toAtom SentenceS}}
      SentenceSs = {String.tokens SentenceS & }
      SentenceAs = {Map SentenceSs S2A}
      GrammarV = {GrammarGenerator.generate SentenceAs PruneB FilterA}
   in
      {ServerO write(vs:GrammarV)}
      {ServerO shutDown(how:[receive send])}
      {ServerO close}
      {Delay 50}
      {MainLoop}
   end
end
