all: spec.ps

spec.dvi: mylatex.fmt \
	spec.tex \
	pix/xdag2eps pix/xdag2pdf pix/xdag.sty

mylatex.fmt: spec.sty jochen.sty
	pdflatex -ini \&latex mylatex.ltx spec.tex

CROSS	= 'Rerun to get cross-references right.|Citation.*undefined'
CITATION = 'Citation.*undefined'

define latex
pdflatex \&mylatex
endef
%.dvi: %.tex %.bib
	cd pix;make;cd ..
	$(latex) $<
	-egrep -s $(CITATION) $*.log && bibtex $*
	-egrep -s $(CROSS) $*.log && $(latex) $<
	-egrep -s $(CROSS) $*.log && $(latex) $<
	-egrep -s $(CROSS) $*.log && $(latex) $<
%.pdf: %.ps
	ps2pdf13 $<
%.ps: %.dvi
	dvips -ta4 -Pcmz -Pamz $< -o $@
clean:
	-rm -fv *~ .*~ \#*\# .\#* *.aux *.bak *.bbl *.blg *.dvi *.eps *.fmt *.idx *.ilg *.log *.out *.pdf *.ps *.tgz *.toc
veryclean:
	cd pix;make clean;cd ..;make clean
