declare
PortI = 4712
[ManualOracle] = {Link ['../../Oracles/ManualOracle/ManualOracle.ozf']}
{ManualOracle.init o(port: PortI)}
class ClientClass from Open.socket Open.text end
Client = {New ClientClass init}
{Client connect(host:localhost port:PortI)}
%%
InitV =
'<init/>'
NewV0 =
'<new id="root" parentid="root">'#
'<description type="full">'#
'<graph dimension="id">'#
'<node index="1" word="string1"/>'#
'<node index="2" word="string2"/>'#
'<node index="3" word="string3"/>'#
'<edge index1="2" index2="3" label="label1"/>'#
'</graph>'#
'<graph dimension="lp">'#
'<node index="1" word="string1" label="nodelabel1"/>'#
'<node index="2" word="string2" label="nodelabel2"/>'#
'<node index="3" word="string3" label="nodelabel3"/>'#
'<edge index1="2" index2="3" label="label1"/>'#
'</graph>'#
'</description>'#
'</new>'
NewV1 =
'<new id="choice1" parentid="root">'#
'<description type="full">'#
'<graph dimension="id">'#
'<node index="1" word="string1"/>'#
'<node index="2" word="string2"/>'#
'<node index="3" word="string3"/>'#
'<edge index1="2" index2="3" label="label1"/>'#
'<edge index1="3" index2="1" label="label2"/>'#
'</graph>'#
'<graph dimension="lp">'#
'<node index="1" word="string1" label="nodelabel1"/>'#
'<node index="2" word="string2" label="nodelabel2"/>'#
'<node index="3" word="string3" label="nodelabel3"/>'#
'<edge index1="2" index2="3" label="label1"/>'#
'<edge index1="3" index2="1" label="label2"/>'#
'</graph>'#
'</description>'#
'</new>'
NewV2 =
'<new id="choice2" parentid="root">'#
'<description type="full">'#
'<graph dimension="id">'#
'<node index="1" word="string1"/>'#
'<node index="2" word="string2"/>'#
'<node index="3" word="string3"/>'#
'<edge index1="2" index2="3" label="label1"/>'#
'<edge index1="2" index2="1" label="label2"/>'#
'</graph>'#
'<graph dimension="lp">'#
'<node index="1" word="string1" label="nodelabel1"/>'#
'<node index="2" word="string2" label="nodelabel2"/>'#
'<node index="3" word="string3" label="nodelabel3"/>'#
'<edge index1="2" index2="3" label="label1"/>'#
'<edge index1="2" index2="1" label="label2"/>'#
'</graph>'#
'</description>'#
'</new>'
ChooseLocalV =
'<chooseLocal refid="root"/>'
ResetV =
'<reset/>'
%%
declare [Helpers] = {Link ['Helpers.ozf']}
%%
proc {Sender}
   S = {Client getS($)}
   Elements = {Helpers.parse S}
in
   {ForAll Elements SenderReact}
   {Sender}
end
%%
proc {SenderReact Element}
   {Inspect client#read#Element}
end
%%
thread {Sender} end
%%
{Client putS(InitV)}
{Delay 100}
{Client putS(ResetV)}
{Delay 100}
{Client putS(NewV0)}
{Delay 100}
{Client putS(NewV1)}
{Delay 100}
{Client putS(NewV2)}
{Delay 100}
{Client putS(ChooseLocalV)}
