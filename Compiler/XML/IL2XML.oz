%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   Inspector(inspect)
%   Ozcar(breakpoint)
%   System(show)

   Helpers(xs2X cIL2A vIL2A escapeSyntaxMarkers) at 'Helpers.ozf'
export
   Convert
define
   fun {Convert1 IL ContextA}
      Coord = {CondSelect IL coord noCoord}
      File = {CondSelect IL file noFile}
   in
      case IL
	 %% 'GRAMMAR'
      of elem(tag: grammar ...) then
	 UseDimensionILs = {CondSelect IL usedimensions nil}
	 DimensionILs = {CondSelect IL dimensions nil}
	 ClassILs = {CondSelect IL classes nil}
	 EntryILs = {CondSelect IL entries nil}
	 %%
	 UseDimensionXMLs =
	 {Map UseDimensionILs
	  fun {$ CIL}
	     A = {Helpers.cIL2A CIL}
	  in
	     '<useDimension idref="'#A#'"/>'
	  end}
	 DimensionXMLs = {Map DimensionILs
			  fun {$ IL1} {Convert1 IL1 noContext} end}
	 ClassXMLs = {Map ClassILs
		      fun {$ IL1} {Convert1 IL1 noContext} end}
	 EntryXMLs = {Map EntryILs
		      fun {$ IL1} {Convert1 IL1 noContext} end}
	 %%
	 UseDimensionsXML = {Helpers.xs2X UseDimensionXMLs '\n'}
	 DimensionsXML = {Helpers.xs2X DimensionXMLs '\n'}
	 ClassesXML = {Helpers.xs2X ClassXMLs '\n'}
	 EntriesXML = {Helpers.xs2X EntryXMLs '\n'}
	 XML = {Helpers.xs2X ['<grammar>'
			      UseDimensionsXML
			      DimensionsXML
			      ClassesXML
			      EntriesXML
			      '</grammar>'] '\n'}
      in
	 XML
	 %% 'DIMENSION'
      [] elem(tag: dimension
	      id: CIL ...) then
	 AttrsIL = {CondSelect IL attrs elem(tag: 'type.record'
					     args: nil)}
	 EntryIL = {CondSelect IL entry elem(tag: 'type.record'
					     args: nil)}
	 LabelIL = {CondSelect IL label elem(tag: 'type.domain'
					     args: nil)}
	 TypeILs = {CondSelect IL types nil}
	 PrincipleILs = {CondSelect IL principles nil}
	 OutputILs = {CondSelect IL outputs nil}
	 UseOutputILs = {CondSelect IL useoutputs nil}
	 %%
	 IDA = {Helpers.cIL2A CIL}
	 AttrsXML = {Convert1 AttrsIL type}
	 EntryXML = {Convert1 EntryIL type}
	 LabelXML = {Convert1 LabelIL type}
	 TypeXMLs = {Map TypeILs
		     fun {$ IL1} {Convert1 IL1 noContext} end}
	 PrincipleXMLs = {Map PrincipleILs
			  fun {$ IL1} {Convert1 IL1 noContext} end}
	 OutputXMLs = {Map OutputILs
		       fun {$ IL1} {Convert1 IL1 noContext} end}
	 UseOutputXMLs = {Map UseOutputILs
			  fun {$ IL1} {Convert1 IL1 noContext} end}
	 %%
	 TypesXML = {Helpers.xs2X TypeXMLs '\n'}
	 PrinciplesXML = {Helpers.xs2X PrincipleXMLs '\n'}
	 OutputsXML = {Helpers.xs2X OutputXMLs '\n'}
	 UseOutputsXML = {Helpers.xs2X UseOutputXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<dimension id="'#IDA#'">'
			      '<attrsType>'
			      AttrsXML
			      '</attrsType>'
			      '<entryType>'
			      EntryXML
			      '</entryType>'
			      '<labelType>'
			      LabelXML
			      '</labelType>'
			      TypesXML
			      PrinciplesXML
			      OutputsXML
			      UseOutputsXML
			      '</dimension>'] '\n'}
      in
	 XML
	 %% 'OUTPUT'
      [] elem(tag: output
	      idref: CIL ...) then
	 IDA = {Helpers.cIL2A CIL}
	 %%
	 XML = '<output idref="'#IDA#'"/>'
      in
	 XML
	 %% 'USEOUTPUT'
      [] elem(tag: useoutput
	      idref: CIL ...) then
	 IDA = {Helpers.cIL2A CIL}
	 %%
	 XML = '<useOutput idref="'#IDA#'"/>'
      in
	 XML
	 %% 'TYPEDEF'
      [] elem(tag: typedef
	      id: CIL
	      type: TypeIL ...) then
	 IDA = {Helpers.cIL2A CIL}
	 TypeXML = {Convert1 TypeIL type}
	 %%
	 XML = {Helpers.xs2X ['<typeDef id="'#IDA#'">'
			      TypeXML
			      '</typeDef>'] '\n'}
      in
	 XML
	 %% 'TYPE'
      [] elem(tag: 'type.domain' ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 type} end}
	 %%
	 ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<typeDomain>'
			      ArgsXML
			      '</typeDomain>'] '\n'}
      in
	 XML
      [] elem(tag: 'type.set'
	      arg: ArgIL ...) then
	 ArgXML = {Convert1 ArgIL type}
	 %%
	 XML = {Helpers.xs2X ['<typeSet>'
			      ArgXML
			      '</typeSet>'] '\n'}
      in
	 XML
      [] elem(tag: 'type.iset'
	      arg: ArgIL ...) then
	 ArgXML = {Convert1 ArgIL type}
	 %%
	 XML = {Helpers.xs2X ['<typeISet>'
			      ArgXML
			      '</typeISet>'] '\n'}
      in
	 XML
      [] elem(tag: 'type.tuple' ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 type} end}
	 %%
	 ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<typeTuple>'
			      ArgsXML
			      '</typeTuple>'] '\n'}
      in
	 XML
      [] elem(tag: 'type.list'
	      arg: ArgIL ...) then
	 ArgXML = {Convert1 ArgIL type}
	 %%
	 XML = {Helpers.xs2X ['<typeList>'
			      ArgXML
			      '</typeList>'] '\n'}
      in
	 XML
      [] elem(tag: 'type.record' ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 type} end}
	 %%
	 XML =
	 if ArgXMLs==nil then
	    '<typeRecord/>'
	 else
	    ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 in
	    {Helpers.xs2X ['<typeRecord>'
			   ArgsXML
			   '</typeRecord>'] '\n'}
	 end
      in
	 XML
      [] elem(tag: 'type.valency'
	      arg: ArgIL ...) then
	 ArgXML = {Convert1 ArgIL type}
	 %%
	 XML = {Helpers.xs2X ['<typeValency>'
			      ArgXML
			      '</typeValency>'] '\n'}
      in
	 XML
      [] elem(tag: 'type.card' ...) then
	 XML = '<typeCard/>'
      in
	 XML
      [] elem(tag: 'type.vec'
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgXML1 = {Convert1 ArgIL1 type}
	 ArgXML2 = {Convert1 ArgIL2 type}
	 %%
	 XML = {Helpers.xs2X ['<typeVec>'
			      ArgXML1 
			      ArgXML2
			      '</typeVec>'] '\n'}
      in
	 XML
      [] elem(tag: 'type.int' ...) then
	 XML = '<typeInt/>'
      in
	 XML
      [] elem(tag: 'type.ints' ...) then
	 XML = '<typeInts/>'
      in
	 XML
      [] elem(tag: 'type.string' ...) then
	 XML = '<typeString/>'
      in
	 XML
      [] elem(tag: 'type.bool' ...) then
	 XML = '<typeBool/>'
      in
	 XML
      [] elem(tag: 'type.ref'
	      idref: CIL ...) then
	 IDA = {Helpers.cIL2A CIL}
	 %%
	 XML = '<typeRef idref="'#IDA#'"/>'
      in
	 XML
      [] elem(tag: 'type.labelref'
	      arg: VIL ...) then
	 A = {Helpers.vIL2A VIL}
	 %%
	 XML = '<typeLabelRef data="'#A#'"/>'
      in
	 XML
      [] elem(tag: 'type.variable'
	      data: A ...) then
	 XML = '<typeVariable data="'#A#'"/>'
      in
	 XML
	 %% 'USEPRINCIPLE'
      [] elem(tag: useprinciple
	      idref: CIL ...) then
	 DimensionILs = {CondSelect IL dimensions nil}
	 ArgILs = {CondSelect IL args nil}
	 %%
	 IDA = {Helpers.cIL2A CIL}
	 DimensionXMLs =
	 {Map DimensionILs
	  fun {$ IL1}
	     VIL#CIL = IL1
	     A = {Helpers.vIL2A VIL}
	     IDA = {Helpers.cIL2A CIL}
	     XML1 = '<dim var="'#A#'" idref="'#IDA#'"/>'
	  in
	     XML1
	  end}
	 ArgXMLs =
	 {Map ArgILs
	  fun {$ IL1}
	     VIL#IL2 = IL1
	     A = {Helpers.vIL2A VIL}
	     XML1 = {Convert1 IL2 term}
	     XML2 = {Helpers.xs2X ['<arg var="'#A#'">'
				   XML1
				   '</arg>'] '\n'}
	  in
	     XML2
	  end}
	 %%
	 DimensionsXML = {Helpers.xs2X DimensionXMLs '\n'}
	 ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<usePrinciple idref="'#IDA#'">'
			      DimensionsXML
			      ArgsXML
			      '</usePrinciple>'] '\n'}
      in
	 XML
	 %% 'CLASSDEF'
      [] elem(tag: classdef
	      id: CIL
	      body: BodyIL ...) then
	 VarILs = {CondSelect IL vars nil}
	 %%
	 IDA = {Helpers.cIL2A CIL}
	 VarXMLs = {Map VarILs
		    fun {$ IL1} {Convert1 IL1 noContext} end}
	 BodyXML = {Convert1 BodyIL 'class'}
	 %%
	 VarsXML = {Helpers.xs2X VarXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<classDef id="'#IDA#'">'
			      VarsXML
			      BodyXML
			       '</classDef>'] '\n'}
      in
	 XML
	 %% 'CLASS'
      [] elem(tag: 'class.dimension'
	      idref: CIL
	      arg: ArgIL ...) then
	 IDA = {Helpers.cIL2A CIL}
	 ArgXML = {Convert1 ArgIL term}
	 XML = {Helpers.xs2X ['<classDimension idref="'#IDA#'">'
			      ArgXML
			      '</classDimension>'] '\n'}
      in
	 XML
      [] elem(tag: 'class.ref'
	      idref: CIL ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 IDA = {Helpers.cIL2A CIL}
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 term} end}
	 %%
	 ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<useClass idref="'#IDA#'">'
			       ArgsXML
			       '</useClass>'] '\n'}
      in
	 XML
      [] elem(tag: conj ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 ContextA} end}
	 %%
	 ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 %%
	 ConjA = case ContextA
		 of 'term' then conj
		 [] 'class' then classConj
		 [] 'record' then recordConj
		 [] 'setGen' then setGenConj
		 else
		    raise error1('functor':'Compiler/XML/IL2XML.ozf' 'proc':'Convert1' msg:'Bad conjunction context '#ContextA info:o(IL) coord:Coord file:File) end
		 end
	 XML = {Helpers.xs2X ['<'#ConjA#'>'
			      ArgsXML
			      '</'#ConjA#'>'] '\n'}
      in
	 XML
      [] elem(tag: disj ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 ContextA} end}
	 %%
	 ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 %%
	 DisjA = case ContextA
		 of 'term' then disj
		 [] 'class' then classDisj
		 [] 'record' then recordDisj
		 [] 'setGen' then setGenDisj
		 else
		    raise error1('functor':'Compiler/XML/IL2XML.ozf' 'proc':'Convert1' msg:'Bad disjunction context '#ContextA info:o(IL) coord:Coord file:File) end
		 end
	 XML = {Helpers.xs2X ['<'#DisjA#'>'
			      ArgsXML
			      '</'#DisjA#'>'] '\n'}
      in
	 XML
      [] elem(tag: concat ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 ContextA} end}
	 %%
	 ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<'#concat#'>'
			      ArgsXML
			      '</'#concat#'>'] '\n'}
      in
	 XML
      [] elem(tag: order ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 ContextA} end}
	 %%
	 XML =
	 if ArgXMLs==nil then
	    '<order/>'
	 else
	    ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 in
	    {Helpers.xs2X ['<'#order#'>'
			   ArgsXML
			   '</'#order#'>'] '\n'}
	 end
      in
	 XML
      [] elem(tag: bounds
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgXML1 = {Convert1 ArgIL1 term}
	 ArgXML2 = {Convert1 ArgIL2 term}
	 %%
	 ArgsXML = {Helpers.xs2X [ArgXML1 ArgXML2] '\n'}
	 %%
	 XML = {Helpers.xs2X ['<'#bounds#'>\n'
			      ArgsXML
			      '</'#bounds#'>'] '\n'}
      in
	 XML
	 %% 'ENTRY'
      [] elem(tag: entry
	      body: BodyIL ...) then
	 BodyXML = {Convert1 BodyIL 'class'}
	 %%
	 XML = {Helpers.xs2X ['<entry>'
			      BodyXML
			      '</entry>'] '\n'}
      in
	 XML
	 %% 'TERM'
	 %% 'CONSTANT'
      [] elem(tag: constant
	      data: A ...) then
	 S = {Helpers.escapeSyntaxMarkers A}
	 XML = '<constant data="'#S#'"/>'
      in
	 XML
	 %% 'VARIABLE'
      [] elem(tag: variable
	      data: A ...) then
	 S = {Helpers.escapeSyntaxMarkers A}
	 XML = '<variable data="'#S#'"/>'
      in
	 XML
	 %% 'INTEGER'
      [] elem(tag: integer
	      data: I ...) then
	 XML = '<integer data="'#I#'"/>'
      in
	 XML
      [] CIL#IL1 then
	 A = {Helpers.cIL2A CIL}
	 %%
	 XML =
	 if ContextA==type then
	    XML1 = {Convert1 IL1 type}
	    XML2 = {Helpers.xs2X ['<typeFeature data="'#A#'">'
				  XML1
				  '</typeFeature>'] '\n'}
	 in
	    XML2
	 elseif ContextA==term orelse ContextA==record then
	    case IL1
	    of elem(tag: 'card.wild'
		    arg: WildA ...) then
	       WildA1 = case WildA
			of '!' then one
			[] '?' then opt
			[] '*' then any
			[] '+' then geone
			else
			   raise error1('functor':'Compiler/XML/IL2XML.ozf' 'proc':'Convert1' msg:'Illformed IL wild card: '#WildA info:o(IL) coord:Coord file:File) end
			end
	       TagA = if CIL.tag==constant then
			 'constantCard'
		      else
			 'variableCard'
		      end
	       XML1 = '<'#TagA#' data="'#A#'" card="'#WildA1#'"/>'
	    in
	       XML1
	    [] elem(tag: 'card.set' ...) then
	       ArgILs = {CondSelect IL1 args nil}
	       %%
	       ArgXMLs = {Map ArgILs
			  fun {$ ArgIL} {Convert1 ArgIL term} end}
	       %%
	       ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	       %%
	       TagA = if CIL.tag==constant then
			 'constantCardSet'
		      else
			 'variableCardSet'
		      end
	       XML1 = {Helpers.xs2X ['<'#TagA#' data="'#A#'">'
				     ArgsXML
				     '</'#TagA#'>'] '\n'}
	    in
	       XML1
	    [] elem(tag: 'card.interval'
		    arg1: ArgIL1
		    arg2: ArgIL2 ...) then
	       ArgXML1 = {Convert1 ArgIL1 term}
	       ArgXML2 = {Convert1 ArgIL2 term}
	       %%
	       TagA = if CIL.tag==constant then
			 'constantCardInterval'
		      else
			 'variableCardInterval'
		      end
	       XML1 = {Helpers.xs2X ['<'#TagA#' data="'#A#'">'
				     ArgXML1
				     ArgXML2
				     '</'#TagA#'>'] '\n'}
	    in
	       XML1
	    else
	       XML1 = {Convert1 IL1 term}
	       TagA = if CIL.tag==constant then
			 'feature'
		      else
			 'varFeature'
		      end
	       XML2 = {Helpers.xs2X ['<'#TagA#' data="'#A#'">'
				     XML1
				     '</'#TagA#'>'] '\n'}
	    in
	       XML2
	    end
	 else
	    raise error1('functor':'Compiler/XML/IL2XML.ozf' 'proc':'Convert1' msg:'Bad context for IL feature (must be type or term or record): '#ContextA info:o(IL) coord:Coord file:File) end
	 end
      in
	 XML
      [] elem(tag: top ...) then
	 XML = '<top/>'
      in
	 XML
      [] elem(tag: bot ...) then
	 XML = '<bot/>'
      in
	 XML
      [] elem(tag: set ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 term} end}
	 %%
	 XML =
	 if ArgXMLs==nil then
	    '<set/>'
	 else
	    ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 in
	    {Helpers.xs2X ['<set>'
			   ArgsXML
			   '</set>'] '\n'}
	 end
      in
	 XML
      [] elem(tag: list ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 term} end}
	 %%
	 XML =
	 if ArgXMLs==nil then
	    '<list/>'
	 else
	    ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 in
	    {Helpers.xs2X ['<list>'
			   ArgsXML
			   '</list>'] '\n'}
	 end
      in
	 XML
      [] elem(tag: record ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgXMLs = {Map ArgILs
		    fun {$ IL1} {Convert1 IL1 record} end}
	 %%
	 ArgsXML = {Helpers.xs2X ArgXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<record>'
			      ArgsXML
			      '</record>'] '\n'}
      in
	 XML
      [] elem(tag: setgen
	      arg: SetGenIL ...) then
	 SetGenXML = {Convert1 SetGenIL setGen}
	 %%
	 XML = {Helpers.xs2X ['<setGen>'
			      SetGenXML
			      '</setGen>'] '\n'}
      in
	 XML
      [] elem(tag: featurepath
	      root: RootA
	      dimension: VIL
	      aspect: AspectA ...) then
	 FieldILs = {CondSelect IL fields nil}
	 %%
	 RootA1 = case RootA
		  of '_' then 'down'
		  [] '^' then 'up'
		  else
		     raise error1('functor':'Compiler/XML/IL2XML.ozf' 'proc':'Convert1' msg:'Illformed IL root variable: '#RootA info:o(IL) coord:Coord file:File) end
		  end
	 A = {Helpers.vIL2A VIL}
	 AspectA1 = case AspectA
		    of 'entry' then 'entry'
		    [] 'attrs' then 'attrs'
		    else
		       raise error1('functor':'Compiler/XML/IL2XML.ozf' 'proc':'Convert1' msg:'Illformed IL aspect: '#AspectA info:o(IL) coord:Coord file:File) end
		    end
	 FieldXMLs = {Map FieldILs
		      fun {$ IL1} {Convert1 IL1 term} end}
	 %%
	 FieldsXML = {Helpers.xs2X FieldXMLs '\n'}
	 %%
	 XML = {Helpers.xs2X ['<featurePath root="'#RootA1#'" dimension="'#A#'" aspect="'#AspectA1#'">'
			      FieldsXML
			      '</featurePath>'] '\n'}
      in
	 XML
      [] elem(tag: annotation
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgXML1 = {Convert1 ArgIL1 term}
	 ArgXML2 = {Convert1 ArgIL2 type}
	 %%
	 XML = {Helpers.xs2X ['<annotation>'
			      ArgXML1
			      ArgXML2
			      '</annotation>'] '\n'}
      in
	 XML
      else
	 raise error1('functor':'Compiler/XML/IL2XML.ozf' 'proc':'Convert1' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
      end
   end
   %%
   fun {Convert IL}
      XML = {Convert1 IL noContext}
   in
      '<?xml version="1.0" encoding="ISO-8859-1"?>\n'#
%      '<!DOCTYPE grammar SYSTEM "../Compiler/XML/xdk.dtd">\n'#
      XML#'\n'
   end
end
