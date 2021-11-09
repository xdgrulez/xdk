declare
{Inspector.configure widgetShowStrings true}
[String1] = {Module.link ['x-oz://system/String.ozf']}
[Regex] = {Module.link ['x-oz://contrib/regex']}
Ss = ["principle.graphPW"
      "principle.climbingSubgraphsPW"
      "principle.agr"
      "principle.subgraphsPW"]
FilterS = "graphPW"
Ss1 = {Filter Ss
       fun {$ S} {List.sub FilterS S} end}
{Inspect 1#Ss1}
Ss2 = {Filter Ss
       fun {$ S}
	  Ss = {String1.splitAtMost S FilterS 1}
       in
	  {Length Ss}==2
       end}
{Inspect 2#Ss2}
RE = {Regex.make "graph.*PW"}
Ss3 = {Filter Ss
       fun {$ S}
	  MATCH = {Regex.search RE S}
       in
	  {Not MATCH==false}
       end}
{Inspect 3#Ss3}
