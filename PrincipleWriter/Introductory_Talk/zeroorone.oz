proc {ZeroOrOneIncomingEdges NodeRecs}
   {ForAllNodes NodeRecs
    fun {$ NodeRec}
       {Disj
	{Nega
	 {ExistsNodes NodeRecs
	  fun {$ NodeRec1} {Edge NodeRec1 NodeRec d} end}}}
	{ExistsOneNodes NodeRecs
	 fun {$ NodeRec1} {Edge NodeRec1 NodeRec d} end}
    end 1}
end
