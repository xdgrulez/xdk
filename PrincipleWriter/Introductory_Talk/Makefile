all: introductory_talk.pdf

introductory_talk.pdf: introductory_talk.tex
	latex introductory_talk.tex
	latex introductory_talk.tex
#	bibtex formal_grammars_slides
	dvips 	introductory_talk.dvi -o introductory_talk.ps
	ps2pdf introductory_talk.ps introductory_talk.pdf

handout:
	latex formal_grammars_slides-ho.tex
#	bibtex formal_grammars_slides
	latex formal_grammars_slides-ho.tex
	latex formal_grammars_slides-ho.tex
	dvips formal_grammars_slides-ho.dvi -o formal_grammars_slides-ho.ps
	ps2pdf formal_grammars_slides-ho.ps formal_grammars_slides-ho.pdf

tar: 
	mkdir tar
	cp introductory_talk.tex tar
	cp Makefile tar
	cp *.eps tar
	tar cvf introductory_talk.tar tar/ && rm -f introductory_talk.tar.bz2
	bzip2 introductory_talk.tar && rm -rf tar

scp: 
	scp introductory_talk.pdf setz@ps.uni-sb.de:~setz/public_html/  
