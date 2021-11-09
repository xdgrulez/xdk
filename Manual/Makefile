all: xdkhtml

%.dvi: %.texi *.texi pix/*.eps
	texi2dvi $< -o $*.dvi
%.guide: %.texi *.texi pix/*.txt
	makeinfo --amiga xdk.texi
%.info: %.texi *.texi pix/*.txt
	makeinfo -v $< -o $*.info
%.pdf: %.ps
	export GS_OPTIONS="-sPAPERSIZE=a4";ps2pdf13 $< $*.pdf
%.ps: %.dvi
	dvips -Pcmz -Pamz $< -o $*.ps

%2up: %.ps
	psnup -2 $< $*2up.ps
%4up: %.ps
	psnup -4 $< $*4up.ps
%html: %.texi *.texi pix/*.jpg
	makeinfo -v --html $<
	mkdir -p $*/pix
	cp -rfv pix/*.jpg $*/pix
clean:
	-rm -rfv *~ .*~ *.aux *.cp *.cps *.dvi *.fn *.guide *.info *.ky *.log *.pg *.pdf *.ps *.toc *.tp *.vr pix/*.bak xdk/ xdk.info*
