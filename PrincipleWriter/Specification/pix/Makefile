GZSOURCES = \

TEXSOURCES = \

GIFSOURCES = \

FIGSOURCES = \

EPSTARGETS = $(GZSOURCES:%.eps.gz=%.eps) $(TEXSOURCES:%.tex=%.eps) $(GIFSOURCES:%.gif=%.eps) $(FIGSOURCES:%.fig=%.eps)
PDFTARGETS = $(GZSOURCES:%.eps.gz=%.pdf) $(TEXSOURCES:%.tex=%.pdf) $(GIFSOURCES:%.gif=%.pdf) $(FIGSOURCES:%.fig=%.pdf)

TEXINPUTS := .:$(TEXINPUTS)
export TEXINPUTS

all: $(EPSTARGETS) #$(PDFTARGETS)

%_gz.eps: %_gz.eps.gz
	gunzip -c $< >$@
%_xdag.eps: %_xdag.tex
	./xdag2eps $<
%_xdag.pdf: %_xdag.tex
	./xdag2pdf $<
%_gif.eps: %_gif.gif
	convert $< $@
%_gif.pdf: %_gif.eps
	epstopdf $< --outfile=$@
%_fig.eps: %_fig.fig
	fig2dev -L eps $< $@
%_fig.pdf: %_fig.eps
	epstopdf $< --outfile=$@
%.eps: %.dvi
	dvips -E $< -o $@
%.pdf: %.dvi
	dvipdf -E $< -o $@
%.dvi: %.tex
	./latex2dvi $<

clean:
	rm -fv *~ .*~ \#*\# .\#* *.aux *.bak *.bbl *.blg *.dvi *.eps *.fmt *.log *.out *.pdf *.ps

.PHONY: all
