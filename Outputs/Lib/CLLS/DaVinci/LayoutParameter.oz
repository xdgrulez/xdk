functor
export
   parameter:LayoutParameter
define
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   %% specification of layout parameter
   %% %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

   LayoutParameter = unit(edge:
			     unit(default:
				     edge('EDGECOLOR':black
					  'EDGEPATTERN':solid
					  '_DIR':normal
					  'HEAD':arrow)
				  dom:
				     edge('EDGECOLOR':blue
					  'EDGEPATTERN':dotted
					  '_DIR':normal)
				  varbind:
				     edge('EDGECOLOR':red
					  'EDGEPATTERN':dashed
					  '_DIR':normal)
				  strictDom:
				     edge('EDGECOLOR'  :'steelblue'
					  'EDGEPATTERN':dotted
					  '_DIR'       :normal)
				  reint:
				     edge('EDGECOLOR':red
					  'EDGEPATTERN':dotted
					  '_DIR':normal)
				  equal:
				     edge('EDGECOLOR':gray
					  '_DIR'     :none)
				  disjoint:
				     edge('EDGECOLOR':gray
					  'HEAD':circle
					  '_DIR':both)
				  lam:
				     edge('EDGECOLOR':green
					  'EDGEPATTERN':dotted
					  '_DIR':inverse
					  'HEAD':arrow)
				  lamInv:
				     edge('EDGECOLOR':green
					  'EDGEPATTERN':dashed
					  '_DIR':inverse
					  'HEAD':arrow)
				  para:
				     edge('EDGECOLOR':brown
					  'EDGEPATTERN':dashed)
				  ana:
				     edge('EDGECOLOR':red
					  'EDGEPATTERN':dashed
					  '_DIR':normal
					  'HEAD':arrow)
				  child:
				     edge
				  void:
				     edge('EDGEPATTERN':none)
				 )
			  node: unit(default:
					unit('COLOR' :white
					     '_GO'   :text
					     'OBJECT':default)
				     redex:
					unit('COLOR' :lightblue)
				     oldRedex:
					unit('COLOR':orange)))
end
