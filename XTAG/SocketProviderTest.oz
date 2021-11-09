declare
PortI = 4712
[SocketProvider] = {Link ['../XTAG/SocketProvider.ozf']}
{SocketProvider.provide o(port:PortI)}
{Inspect 'server running on port '#PortI}

declare
class SocketK from Open.socket Open.text end
ClientO = {New SocketK init}
{ClientO connect(host:localhost port:PortI)}
{ClientO write(vs:'women every man loves')}
{ClientO shutDown(how:[send])}
V = {ClientO read(list:$ size:all)}
{Inspect {VirtualString.toAtom V}}
{ClientO close}
