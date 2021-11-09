LATEX=latex

all: 
	$(LATEX) Thesis.tex
	bibtex Thesis
	$(LATEX) Thesis.tex
	$(LATEX) Thesis.tex
	$(LATEX) Thesis.tex

clean:
	/usr/bin/rm -fv *~ .*~ \#*\# .\#* *.aux *.bak *.bbl *.blg *.dvi *.eps *.fmt *.idx *.ilg *.log *.out *.pdf *.ps
