%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Ozcar(breakpoint)
   System(show)
   
   Inspector(inspect)
   
   Module(link)
   Open(socket)
   Pickle(load)
   
   Helpers(getSuffix v2PortI cIL2A iIL2I) at 'Helpers.ozf'
   
   ULParser(parseUrl) at 'UL/Parser.ozf'
   UL2IL(convert) at 'UL/UL2IL.ozf'

   XMLParser(parseUrl parseV) at 'XML/Parser.ozf'
   XML2IL(convert) at 'XML/XML2IL.ozf'
   
   TypeChecker(check) at 'TypeChecker.ozf'
export
   IsSupportedSuffix

   PartitionAs
   As2WordAs
   As2FileAs
   
   FileAs2NodesProc
prepare
   ListPartition = List.partition
   RecordToDictionary = Record.toDictionary
define
   %% IsSupportedSuffix: S -> B
   %% Checks whether S is a supported suffix.
   fun {IsSupportedSuffix S}
      {Member S ["ul" "xml" "ilp" "ozf" "xmlsocket"]}
   end
   %% PartitionAs: As -> WordAsFileAsTup
   %% Partition list of atoms As into a list of words WordAs and a list of
   %% files FileAs.
   fun {PartitionAs As}
      WordAs
      FileAs
      {ListPartition As
       fun {$ A}
	  A=='#' orelse
	  local
	     S = {Helpers.getSuffix A}
	  in
	     {Not {IsSupportedSuffix S}}
	  end
       end WordAs FileAs}
   in
      WordAs#FileAs 
   end
   %% As2WordAs: As -> WordAs
   fun {As2WordAs As}
      WordAs#_ = {PartitionAs As}
   in
      WordAs
   end
   %% As2FileAs: As -> FileAs
   fun {As2FileAs As}
      _#FileAs = {PartitionAs As}
   in
      FileAs
   end
   %% FileAs2NodesProc: FileAs I G MetaX DebugB PrintProc -> NodesProc
   %% Encodes nodes files in FileAs, where the input has length I, and
   %% the grammar is G. MetaX is meta data for socket communication.
   %% Prints out debugging information if DebugB==true, and is quiet
   %% otherwise. Prints out progress information with procedure
   %% PrintProc.
   fun {FileAs2NodesProc FileAs I G MetaX DebugB PrintProc}
      NodesProcs =
      {Map FileAs
       fun {$ FileA}
	  SuffixS = {Helpers.getSuffix FileA}
       in
	  case SuffixS
	  of "ul" then {ULFile2NodesProc FileA I G DebugB PrintProc}
	  [] "xml" then {XMLFile2NodesProc FileA I G DebugB PrintProc}
	  [] "xmlsocket" then {XMLSocket2NodesProc FileA I G MetaX DebugB PrintProc}
	  [] "ilp" then {ILPickle2NodesProc FileA I G DebugB PrintProc}
	  [] "ozf" then {ILFunctor2NodesProc FileA I G DebugB PrintProc}
	  else
	     raise error1('functor':'Compiler/NodesCompiler.ozf' 'proc':'FileAs2Nodes' msg:'Unsupported suffix.' info:o(FileA) coord:noCoord file:noFile) end
	  end
       end}
   in
      fun {$}
	 for NodesProc in NodesProcs append:Append do
	    Nodes = {NodesProc}
	 in
	    {Append Nodes}
	 end
      end
   end
   %% ULFile2NodesProc: V I G DebugB PrintProc -> NodesProc
   fun {ULFile2NodesProc V I G DebugB PrintProc}
      UL = {ULParser.parseUrl V}
      IL = {UL2IL.convert UL}
      NodesProc = fun {$} {EncodeNodes IL I G DebugB PrintProc} end
   in
      NodesProc
   end
   %% XMLFile2NodesProc: V I G DebugB PrintProc -> NodesProc
   fun {XMLFile2NodesProc V I G DebugB PrintProc}
      Elements = {XMLParser.parseUrl V}
      IL = {XML2IL.convert Elements}
      NodesProc = fun {$} {EncodeNodes IL I G DebugB PrintProc} end
   in
      NodesProc
   end
   %% ILPickle2NodesProc: V I G DebugB PrintProc -> NodesProc
   fun {ILPickle2NodesProc V I G DebugB PrintProc}
      IL = {Pickle.load V}
      NodesProc = fun {$} {EncodeNodes IL I G DebugB PrintProc} end
   in
      NodesProc
   end
   %% ILFunctor2NodesProc: V I G DebugB PrintProc -> NodesProc
   fun {ILFunctor2NodesProc V I G DebugB PrintProc}
      [Functor] = {Module.link [V]}
      if {Not {HasFeature Functor set}} then
	 raise error1('functor':'Compiler/NodesCompiler.ozf' 'proc':'ILFunctor2NodesProc' msg:'Oz functor is no IL node set functor: it does not export the node set under the key "set".' info:o(V) coord:noCoord file:noFile) end
      end
      IL = Functor.set
      NodesProc = fun {$} {EncodeNodes IL I G DebugB PrintProc} end
   in
      NodesProc
   end
   %% XMLVS2NodesProc: V I G DebugB PrintProc -> NodesProc
   fun {XMLVS2NodesProc V I G DebugB PrintProc}
      Elements = {XMLParser.parseV V}
      IL = {XML2IL.convert Elements}
      NodesProc = fun {$} {EncodeNodes IL I G DebugB PrintProc} end
   in
      NodesProc
   end
   %% XMLSocket2NodesProc: V MetaX I G DebugB PrintProc -> NodesProc
   class SocketK from Open.socket end
   %%
   fun {XMLFromSocket PortI MetaX}
      ClientO = {New SocketK init}
      {ClientO connect(host:localhost port:PortI)}
      {ClientO write(vs:MetaX)}
      {ClientO shutDown(how:[send])}
      V = {ClientO read(list:$ size:all)}
   in
      {ClientO close}
      V
   end
   %%
   fun {XMLSocket2NodesProc V I G MetaX DebugB PrintProc}
      PortI = {Helpers.v2PortI V}
      V1 = {XMLFromSocket PortI MetaX}
      if V1==false then
	 raise error1('functor':'Compiler/NodesCompiler.ozf' 'proc':'XMLSocket2SLE' msg:'Could not obtain XML grammar from socket (port '#PortI#').' info:o(V) coord:noCoord file:noFile) end
      end
      %%
      NodesProc = {XMLVS2NodesProc V1 I G DebugB PrintProc}
   in
      NodesProc
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% EncodeNodes: IL I G DebugB PrintProc -> Nodes 
   %% Encode nodes in IL set IL, where the input length is I, and the
   %% grammar is G. DebugB and PrintProc are as above.
   fun {EncodeNodes IL I G DebugB PrintProc}
      if {Not IL.tag=='set'} then
	 Coord = {CondSelect IL coord noCoord}
	 File = {CondSelect IL file noFile}
      in
	 raise error1('functor':'Compiler/NodesCompiler.ozf' 'proc':'EncodeNodes' msg:'A node set is not a set.' info:o coord:Coord file:File) end
      end
      ILs = IL.args
      %%
      Node1Tn = G.node1Tn
      Node1Lat = G.node1Lat
      TnTypeRec = G.tnTypeRec
      TnTypeDict = {RecordToDictionary TnTypeRec}
      %%
      Nodes =
      {Map ILs
       fun {$ IL}
	  %% check type
	  IL1 = elem(tag: annotation
		     arg1: IL
		     arg2: Node1Tn)
	  IL2#_#_ = {TypeChecker.check IL1 TnTypeDict o}
	  %% check indices
	  IILs =
	  for CIL#IL in IL2.args collect:Collect do
	     A = {Helpers.cIL2A CIL}
	  in
	     if A==index then
		I = {Helpers.iIL2I IL}
	     in
		{Collect I#IL}
	     end
	  end
	  if IILs==nil then
	     Coord = {CondSelect IL coord noCoord}
	     File = {CondSelect IL file noFile}
	  in
	     raise error1('functor':'Compiler/NodesCompiler.ozf' 'proc':'EncodeNodes' msg:'Node does not have an index.' info:o(IL) coord:Coord file:File) end
	  end
	  for I1#IL1 in IILs do
	     if I1>I then
		Coord = {CondSelect IL1 coord noCoord}
		File = {CondSelect IL1 file noFile}
	     in
		raise error1('functor':'Compiler/NodesCompiler.ozf' 'proc':'EncodeNodes' msg:'Node index too high: '#I1#', only '#I#' words in input.' info:o(IL IL1) coord:Coord file:File) end
	     end
	  end
	  %% encode
	  Nodes = {Node1Lat.encode IL2 o#{NewDictionary}#false}
	  %% check for disjunction
	  if {Length Nodes}>1 then
	     Coord = {CondSelect IL2 coord noCoord}
	     File = {CondSelect IL2 file noFile}
	  in
	     raise error1('functor':'Compiler/NodesCompiler.ozf' 'proc':'EncodeNodes' msg:'Disjunction not allowed in node sets.' info:o(IL2) coord:Coord file:File) end
	  end
       in
	  Nodes.1
       end}
   in
      Nodes
   end
end
