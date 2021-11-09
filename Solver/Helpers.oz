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

   Open(file text)
export
   PutLines
   Zip1
prepare
   ListZip = List.zip
   RecordZip = Record.zip
define
   %% PutLines: Vs UrlV -> U
   %% Creates a file with URL UrlV and fills it with the lines Vs.
   class TextFileK from Open.file Open.text end
   %%
   proc {PutLines Vs UrlV}
      FileO = {New TextFileK init(name: UrlV
				  flags: [create truncate write text])}
   in
      for V in Vs do {FileO putS(V)} end
      {FileO close}
   end
   %% Zip1: X Y Proc -> SL
   %% Combines  List.zip and Record.zip.
   fun {Zip1 X Y Proc}
      if {IsDet X} andthen {IsDet Y} then
	 if {IsList X} then
	    {ListZip X Y
	     fun {$ X1 Y1} {Zip1 X1 Y1 Proc} end}
	 elseif {IsRecord X} andthen {Width X}>0 then
	    {RecordZip X Y
	     fun {$ X1 Y1}
		{Zip1 X1 Y1 Proc} end}
	 else
	    {Proc X Y}
	 end
      else
	 {Proc X Y}
      end
   end
end
