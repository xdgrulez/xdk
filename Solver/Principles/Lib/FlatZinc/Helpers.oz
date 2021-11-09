%% Copyright 2001-2011
%% by Ralph Debusmann <rade@ps.uni-sb.de> (Saarland University) and
%%    Denys Duchier <duchier@ps.uni-sb.de> (LIFO, Orleans) and
%%    Jorge Marques Pelizzoni <jpeliz@icmc.usp.br> (ICMC, Sao Paulo) and
%%    Jochen Setz <info@jochensetz.de> (Saarland University)
%%
functor
import
%   System(show)

   FS(reflect)
export
   Xs2X

   Var
   Constraint
   Branch
   Output
   
   CSP2FZ
prepare
   ListNumber = List.number
define
   %% Xs2X: Xs SepA -> X
   %% Folds Xs into X.
   %% SepA is the separator (usually '\n' or ' ').
   fun {Xs2X Xs SepA}
      if Xs==nil then ''
      else
	 X1|Xs1 = Xs
	 X =
	 {FoldL Xs1
	  fun {$ AccX X} AccX#SepA#X end X1}
      in
	 X
      end
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% FZTypeA ::= int|bool|set of int
   %% CSPTypeA ::= fd|fdbool|fs
   fun {Var FZTypeA}
      CSPTypeA = case FZTypeA
		 of int then fd
		 [] int#_ then fd
		 [] bool then fdbool
		 [] 'set of int' then fs
		 end
      FZTypeV = case FZTypeA
		of int then '1..134217726'
		[] int#RangeV then RangeV
		[] bool then bool
		[] 'set of int' then '0..134217726'
		end
   in
      var#('var '#FZTypeV#': '#(CSPTypeA#_)#';')
   end
   fun {Constraint BuiltinA FZArgs}
      FZArg = {Xs2X FZArgs ', '}
   in
      constraint#('constraint '#BuiltinA#'('#FZArg#');')
   end
   fun {Branch BuiltinA FZArgs}
      FZArg = {Xs2X FZArgs ', '}
   in
      branch#('  :: '#BuiltinA#'('#FZArg#')')
   end
   fun {Output FZArgs}
      FZArg = {Xs2X FZArgs ', '}
   in
      output#(' ['#FZArg#'];')
   end
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   fun {CSP2FZ CSP}
      case CSP
      of kinded(int)#I then fd#I
      [] kinded(bool)#I then fdbool#I
      [] kinded(fset)#I then fs#I
      [] det(int)#I then I
      [] det(bool)#I then if I==1 then 'true' else 'false' end
      [] det(fset)#M then
	 MSpec = {FS.reflect.lowerBound M}
      in
	 case MSpec
	 of nil then '{}'
	 [] [I1#I2] then I1#'..'#I2
	 [] [I] then '{'#I#'}'
	 elseif {IsList MSpec} then
	    Is = for X in MSpec append:Append do
		    case X
		    of I1#I2 then
		       Is = {ListNumber I1 I2 1}
		    in
		       {Append Is}
		    [] I then
		       {Append [I]}
		    end
		 end
	 in
	    '{'#{Xs2X Is ','}#'}'
	 end
      [] det(tuple)#[det(int)#I1 det(int)#I2] then I1#'..'#I2
      [] det(tuple)#CSPs then
	 FZs = {Map CSPs CSP2FZ}
      in
	 '['#{Xs2X FZs ','}#']'
      [] det(list)#CSPs then
	 FZs = {Map CSPs CSP2FZ}
      in
	 '['#{Xs2X FZs ','}#']'
      else raise error1('functor':'Solver/Principles/Lib/FlatZinc/Helpers.ozf' 'proc':'CSP2FZ' msg:'Unsupported CSP expression.' info:o(CSP) coord:noCoord file:noFile) end
      end
   end
end
