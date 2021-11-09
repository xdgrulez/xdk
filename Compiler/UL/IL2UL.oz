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

   Helpers(xs2X a2CUL cIL2CUL vIL2VUL) at 'Helpers.ozf'
export
   Convert
define
   fun {ConvertSetGen IL}
      Coord = {CondSelect IL coord noCoord}
      File = {CondSelect IL file noFile}
   in
      case IL
      of elem(tag: constant
	      data: A ...) then
	 CUL = {Helpers.a2CUL A}
      in
	 CUL
      [] elem(tag: conj ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs ConvertSetGen}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' \& '}
	 %%
	 UL = '('#ArgsUL#')'
      in
	 UL
      [] elem(tag: disj ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs ConvertSetGen}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' | '}
	 %%
	 UL = '('#ArgsUL#')'
      in
	 UL
      else
	 raise error1('functor':'Compiler/UL/IL2UL.ozf' 'proc':'ConvertSetGen' msg:'Illformed IL set generator expession.' info:o(IL) coord:Coord file:File) end
      end
   end
   %%
   fun {Convert IL}
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
	 UseDimensionULs = {Map UseDimensionILs Convert}
	 DimensionULs = {Map DimensionILs Convert}
	 ClassULs = {Map ClassILs Convert}
	 EntryULs = {Map EntryILs Convert}
	 %%
	 UseDimensionULs1 = {Map UseDimensionULs
			     fun {$ UseDimensionUL}
				'usedim '#UseDimensionUL
			     end}
	 %%
	 UseDimensionsUL = {Helpers.xs2X UseDimensionULs1 '\n'}
	 DimensionsUL = {Helpers.xs2X DimensionULs '\n'}
	 ClassesUL = {Helpers.xs2X ClassULs '\n'}
	 EntriesUL = {Helpers.xs2X EntryULs '\n'}
	 UL = {Helpers.xs2X [UseDimensionsUL
			     DimensionsUL
			     ClassesUL
			     EntriesUL] '\n'}#'\n'
      in
	 UL
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
	 IDCUL = {Helpers.cIL2CUL CIL}
	 AttrsUL = {Convert AttrsIL}
	 EntryUL = {Convert EntryIL}
	 LabelUL = {Convert LabelIL}
	 TypeULs = {Map TypeILs Convert}
	 PrincipleULs = {Map PrincipleILs Convert}
	 OutputULs = {Map OutputILs Convert}
	 UseOutputULs = {Map UseOutputILs Convert}
	 %%
	 TypesUL = {Helpers.xs2X TypeULs '\n'}
	 PrinciplesUL = {Helpers.xs2X PrincipleULs '\n'}
	 OutputsUL = {Helpers.xs2X OutputULs '\n'}
	 UseOutputsUL = {Helpers.xs2X UseOutputULs '\n'}
	 %%
	 UL = {Helpers.xs2X ['defdim '#IDCUL#' {'
			     'defattrstype '#AttrsUL
			     'defentrytype '#EntryUL
			     'deflabeltype '#LabelUL
			     TypesUL
			     PrinciplesUL
			     OutputsUL
			     UseOutputsUL
			     '}'] '\n'}
      in
	 UL
	 %% 'OUTPUT'
      [] elem(tag: output
	      idref: CIL ...) then
	 IDCUL = {Helpers.cIL2CUL CIL}
	 %%
	 UL = 'output '#IDCUL
      in
	 UL
	 %% 'USEOUTPUT'
      [] elem(tag: useoutput
	      idref: CIL ...) then
	 IDCUL = {Helpers.cIL2CUL CIL}
	 %%
	 UL = 'useoutput '#IDCUL
      in
	 UL
	 %% 'TYPEDEF'
      [] elem(tag: typedef
	      id: CIL
	      type: TypeIL ...) then
	 IDCUL = {Helpers.cIL2CUL CIL}
	 TypeUL = {Convert TypeIL}
	 %%
	 UL = 'deftype '#IDCUL#' '#TypeUL
      in
	 UL
	 %% 'TYPE'
      [] elem(tag: 'type.domain' ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' '}
	 %%
	 UL = '{'#ArgsUL#'}'
      in
	 UL
      [] elem(tag: 'type.set'
	      arg: ArgIL ...) then
	 ArgUL = {Convert ArgIL}
	 %%
	 UL = 'set('#ArgUL#')'
      in
	 UL
      [] elem(tag: 'type.iset'
	      arg: ArgIL ...) then
	 ArgUL = {Convert ArgIL}
	 %%
	 UL = 'iset('#ArgUL#')'
      in
	 UL
      [] elem(tag: 'type.tuple' ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' '}
	 %%
	 UL = 'tuple('#ArgsUL#')'
      in
	 UL
      [] elem(tag: 'type.list'
	      arg: ArgIL ...) then
	 ArgUL = {Convert ArgIL}
	 %%
	 UL = 'list('#ArgUL#')'
      in
	 UL
      [] elem(tag: 'type.record' ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs '\n'}
	 %%
	 UL = if ArgULs==nil then
		 '{ : }'
	      else
		 {Helpers.xs2X ['{'
				ArgsUL
				'}'] '\n'}
	      end
      in
	 UL
      [] elem(tag: 'type.valency'
	      arg: ArgIL ...) then
	 ArgUL = {Convert ArgIL}
	 %%
	 UL = 'valency('#ArgUL#')'
      in
	 UL
      [] elem(tag: 'type.card' ...) then
	 UL = 'card'
      in
	 UL
      [] elem(tag: 'type.vec'
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgUL1 = {Convert ArgIL1}
	 ArgUL2 = {Convert ArgIL2}
	 %%
	 UL = 'vec('#ArgUL1#' '#ArgUL2#')'
      in
	 UL
      [] elem(tag: 'type.int' ...) then
	 UL = 'int'
      in
	 UL
      [] elem(tag: 'type.ints' ...) then
	 UL = 'ints'
      in
	 UL
      [] elem(tag: 'type.string' ...) then
	 UL = 'string'
      in
	 UL
      [] elem(tag: 'type.bool' ...) then
	 UL = 'bool'
      in
	 UL
      [] elem(tag: 'type.ref'
	      idref: CIL ...) then
	 IDCUL = {Helpers.cIL2CUL CIL}
	 %%
%	 UL = 'ref('#IDCUL#')'
	 UL = IDCUL
      in
	 UL
      [] elem(tag: 'type.labelref'
	      arg: VIL ...) then
	 VUL = {Helpers.vIL2VUL VIL}
	 %%
	 UL = 'label('#VUL#')'
      in
	 UL
      [] elem(tag: 'type.variable'
	      data: A ...) then
	 UL = 'tv('#A#')'
      in
	 UL
	 %% 'USEPRINCIPLE'
      [] elem(tag: useprinciple
	      idref: CIL ...) then
	 DimensionILs = {CondSelect IL dimensions nil}
	 ArgILs = {CondSelect IL args nil}
	 %%
	 IDCUL = {Helpers.cIL2CUL CIL}
	 DimensionULs = {Map DimensionILs Convert}
	 ArgULs = {Map ArgILs Convert}
	 %%
	 DimensionsUL = {Helpers.xs2X DimensionULs '\n'}
	 ArgsUL = {Helpers.xs2X ArgULs '\n'}
	 %%
	 UL = {Helpers.xs2X ['useprinciple '#IDCUL#' {'
			     'dims {'
			     DimensionsUL
			     '}'
			     'args {'
			     ArgsUL
			     '}'
			     '}'] '\n'}
      in
	 UL
	 %% 'CLASSDEF'
      [] elem(tag: classdef
	      id: CIL
	      body: BodyIL ...) then
	 VarILs = {CondSelect IL vars nil}
	 %%
	 IDCUL = {Helpers.cIL2CUL CIL}
	 VarULs = {Map VarILs Convert}
	 BodyUL = {Convert BodyIL}
	 %%
	 VarsUL = {Helpers.xs2X VarULs ' '}
	 %%
	 UL = {Helpers.xs2X ['defclass '#IDCUL#' '#VarsUL#' {'
			     BodyUL
			     '}'] '\n'}
      in
	 UL
	 %% 'CLASS'
      [] elem(tag: 'class.dimension'
	      idref: CIL
	      arg: ArgIL ...) then
	 IDCUL = {Helpers.cIL2CUL CIL}
	 ArgUL = {Convert ArgIL}
	 UL = {Helpers.xs2X ['dim '#IDCUL
			     ArgUL] '\n'}
      in
	 UL
      [] elem(tag: 'class.ref'
	      idref: CIL ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 IDCUL = {Helpers.cIL2CUL CIL}
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs '\n'}
	 %%
% 	 UL = {Helpers.xs2X ['useclass '#IDCUL#' {'
% 			     ArgsUL
% 			     '}'] '\n'}
	 UL = {Helpers.xs2X [IDCUL#' {'
			     ArgsUL
			     '}'] '\n'}
      in
	 UL
      [] elem(tag: conj ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' \&\n'}
	 %%
	 UL = '('#ArgsUL#')'
      in
	 UL
      [] elem(tag: disj ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' |\n'}
	 %%
	 UL = '('#ArgsUL#')'
      in
	 UL
      [] elem(tag: concat ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' @\n'}
	 %%
	 UL = '('#ArgsUL#')'
      in
	 UL
      [] elem(tag: order ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' '}
	 %%
	 UL = '<'#ArgsUL#'>'
      in
	 UL
      [] elem(tag: bounds
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgUL1 = {Convert ArgIL1}
	 ArgUL2 = {Convert ArgIL2}
	 %%
	 UL = ArgUL1#'/'#ArgUL2
      in
	 UL
	 %% 'ENTRY'
      [] elem(tag: entry
	      body: BodyIL ...) then
	 BodyUL = {Convert BodyIL}
	 %%
	 UL = {Helpers.xs2X ['defentry {'
			     BodyUL
			     '}'] '\n'}
      in
	 UL
	 %% 'TERM'
	 %% 'CONSTANT'
      [] elem(tag: constant
	      data: A ...) then
	 CUL = {Helpers.a2CUL A}
      in
	 CUL
	 %% 'VARIABLE'
      [] elem(tag: variable
	      data: A ...) then
	 CUL = {Helpers.a2CUL A}
      in
	 CUL
	 %% 'INTEGER'
      [] elem(tag: integer
	      data: I ...) then
	 I
	 %% 'CARD'
      [] elem(tag: 'card.wild'
	      arg: WildA ...) then
	 UL = case WildA
	      of '!' then '!'
	      [] '?' then '?'
	      [] '*' then '*'
	      [] '+' then '+'
	      else
		 raise error1('functor':'Compiler/UL/IL2UL.ozf' 'proc':'Convert' msg:'Illformed IL wild card: '#WildA info:o(IL) coord:Coord file:File) end
	      end
      in
	 UL
      [] elem(tag: 'card.set' ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' '}
	 %%
	 UL = '{'#ArgsUL#'}'
      in
	 UL
      [] elem(tag: 'card.interval'
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgUL1 = {Convert ArgIL1}
	 ArgUL2 = {Convert ArgIL2}
	 %%
	 UL = '['#ArgUL1#' '#ArgUL2#']'
      in
	 UL
      [] CIL#IL1 then
	 CUL = {Helpers.cIL2CUL CIL}
	 %%
	 SepA = case IL1.tag
		of 'card.wild' then ''
		[] 'card.set' then "#"
		[] 'card.interval' then "#"
		else ': '
		end
	 %%
	 UL1 = {Convert IL1}
	 %%
	 UL = CUL#SepA#UL1
      in
	 UL
      [] elem(tag: top ...) then
	 UL = top
      in
	 UL
      [] elem(tag: bot ...) then
	 UL = bot
      in
	 UL
      [] elem(tag: set ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' '}
	 %%
	 UL = '{'#ArgsUL#'}'
      in
	 UL
      [] elem(tag: list ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs ' '}
	 %%
	 UL = '['#ArgsUL#']'
      in
	 UL
      [] elem(tag: record ...) then
	 ArgILs = {CondSelect IL args nil}
	 %%
	 ArgULs = {Map ArgILs Convert}
	 %%
	 ArgsUL = {Helpers.xs2X ArgULs '\n'}
	 %%
	 UL = if ArgULs==nil then
		 '{ : }'
	      else
		 {Helpers.xs2X ['{'
				ArgsUL
				'}'] '\n'}
	      end
      in
	 UL
      [] elem(tag: setgen
	      arg: SetGenIL ...) then
	 SetGenUL = {ConvertSetGen SetGenIL}
	 %%
	 UL = '($ '#SetGenUL#')'
      in
	 UL
      [] elem(tag: featurepath
	      root: RootA
	      dimension: VIL
	      aspect: AspectA ...) then
	 FieldILs = {CondSelect IL fields nil}
	 %%
	 RootA1 = case RootA
		  of '_' then '_'
		  [] '^' then '^'
		  else
		     raise error1('functor':'Compiler/UL/IL2UL.ozf' 'proc':'Convert' msg:'Illformed IL root variable: '#RootA info:o(IL) coord:Coord file:File) end
		  end
	 VUL = {Helpers.vIL2VUL VIL}
	 AspectA1 = case AspectA
		    of 'entry' then 'entry'
		    [] 'attrs' then 'attrs'
		    else
		       raise error1('functor':'Compiler/UL/IL2UL.ozf' 'proc':'Convert' msg:'Illformed IL aspect: '#AspectA info:o(IL) coord:Coord file:File) end
		    end
	 FieldULs = {Map FieldILs Convert}
	 %%
	 FieldsUL = {Helpers.xs2X FieldULs '.'}
	 %%
	 UL = {Helpers.xs2X [RootA1
			     VUL
			     AspectA1
			     FieldsUL] '.'}
      in
	 UL
      [] elem(tag: annotation
	      arg1: ArgIL1
	      arg2: ArgIL2 ...) then
	 ArgUL1 = {Convert ArgIL1}
	 ArgUL2 = {Convert ArgIL2}
	 %%
	 UL = ArgUL1#'::'#ArgUL2
      in
	 UL
      else
	 raise error1('functor':'Compiler/UL/IL2UL.ozf' 'proc':'Convert' msg:'Illformed IL expression.' info:o(IL) coord:Coord file:File) end
      end
   end
end
