declare
fun {ReifiedInclude D M}
   D1 = {FD.int 0#1}
in
   thread
      or {FS.include D M}
	 D1=1
      [] {FS.exclude D M}
	 D1=0
      end
   end
   D1
end
proc {Test Sol}
   M = {FS.var.upperBound [1 2 3]}
   D = {FS.reified.include 67 M}
in
   Sol = D
end
D = {Search.base.all Test}
{Inspect D}

/*
Date: Thu, 19 Jul 2007 20:15:43 -0300 (BRT)
From: Jorge Marques Pelizzoni <jpeliz@icmc.usp.br>
To: users@mozart-oz.org
Cc: rade@ps.uni-sb.de
Subject: bug in FS.reified.include


Hi, all!

Strictly speaking, this may not be a real bug, but is indeed very strange,
misleading behaviour. It seems that in an expression like:

{FS.reified.include D M B}

if D and M are determined, but D > 63 and M contains only elements <= 63,
then B will not get determined (!) after {Space.waitStable}. I must
concede, however, that failure ensues if B is bound (e.g. by distribution)
to an invalid value (i.e. 1).

Here is code that demonstrates this oddity:

----------------
declare
proc {Test Sol}
   I = {Space.choose 1024}
   J = {Space.choose 1024}
   S = {FS.value.make [1#J]}
   R = {FS.reified.include I S}
in
   Sol = I#J#R
   {Space.waitStable}
   if {IsDet R} then fail end
   choice
      R = 0
   [] R = 1
   end
end
Strange = {Search.all Test 0 _}
----------------

Cheers, Jorge.
*/
