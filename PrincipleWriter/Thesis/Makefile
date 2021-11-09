LATEX=latex

all: PDF/Thesis.pdf

PDF/Thesis.pdf: Thesis.ps
	/usr/local/bin/ps2pdf $<
	/bin/cp Thesis.pdf PDF/Thesis.pdf
	
Thesis.ps: Thesis.dvi
	cd TeX; dvips $< -o ../$@; cd ..
	
Thesis.dvi: TeX/Thesis.tex TeX/XDG.tex TeX/XDK.tex TeX/Conclusion.tex TeX/Grammatik.tex TeX/Intro.tex TeX/IntroPW.tex TeX/jochen.sty TeX/Optimierung.tex TeX/RelatedWork.tex TeX/Semantik.tex TeX/Thesis.sty TeX/TypeInf.tex TeX/Appendixdl.tex TeX/Appendixgram.tex TeX/Appendixtype.tex TeX/Appendixsem.tex TeX/Title.tex
#	/usr/bin/make -C TeX
	cd TeX; make; cd ..
	/bin/cp TeX/Thesis.dvi .	

clean:
	rm -fv *~ .*~ \#*\# .\#* *.aux *.bak *.bbl *.blg *.dvi *.eps *.fmt *.idx *.ilg *.log *.out *.pdf *.ps *.tgz *.toc 
	rm -fv PDF/*
	make -C TeX clean