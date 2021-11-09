declare
NS
FileO = {New Open.file init(name:'Grammars/diss.nodeset.xml' flags:[read])}
{FileO read(list:NS size:all)}
{FileO close}
class SocketK from Open.socket end
proc {Server PortI}
   ServerO = {New SocketK init}
in
   {ServerO bind(takePort:PortI)}
   {ServerO listen}
   for do
      ClientO = {ServerO accept(accepted:$ acceptClass:SocketK)}
   in
      thread
	 {Inspect 'client accepted'}
	 S = {ClientO read(list:$ size:all)}
	 {Inspect 'server read '#{VirtualString.toAtom S}}
      in
	 {ClientO write(vs:NS)}
	 {ClientO shutDown(how:[send])}
      end
   end
end
PortI = 4712
thread {Server PortI} end
{Inspect 'node set server is running'}

declare
fun {InitClient}
   ClientO = {New SocketK init}
   {ClientO connect(host:localhost port:PortI)}
in
   ClientO
end
ClientO = {InitClient}
{ClientO write(vs:"mary_L+H*_LH% sees the man with a telescope_H*_LL% .")}
{ClientO shutDown(how:[send])}
V = {ClientO read(list:$ size:all)}
{Inspect 'client read '#{VirtualString.toAtom V}}
{ClientO close}
