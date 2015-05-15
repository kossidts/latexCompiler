#!/bin/bash

#/*
# *  latexCompiler.sh
# *		compile latex source code to build pdf-document 
# *
# *     Created on: 24. 11. 2013
# *  last modified: 15. 05. 2015
# *         Author: KDTS
# *        Version: 1.0.0
# */


#---------------------- CONFIGURATION PART ----------------------#  
##INFO:: 
##		the command line options/arguments have hiher priority and can overwrite this settings
##		
#name of the teX-document to be compiled i.e.: 
		# TEX_FILE="document.tex"  or 
		# TEX_FILE="/path/to/document.text" --> if the document is not located in the same directory as this script
TEX_FILE=""

#name of the Gnuplot-(frame)file to plot images i.e.: 
		# PLOT_FILE="plot.tpl"  or 
		# PLOT_FILE="/path/to/plot.tpl" --> if the document is not located in the same directory as this script
PLOT_FILE=""

#name of the BibTeX-file for references i.e.: 
		# BIB_FILE="literatur.bib"  or 
		# BIB_FILE="/path/to/literatur.bib" --> if the document is not located in the same directory as this script
BIB_FILE=""

#clear files i.e. delete unnecessary files *(.aux, .out, .toc, .bcf ....)   [yes|no] (by default yes)
CLEAR="yes"

#does the tex-document include svg file? [yes|no] (by default no)
SVG="no" 

#create index page? [yes|no] (by default no)
MAKEINDEX="no" 

#------------------ END OF CONFIGURATION PART --------------------# 





#---------------------- usage statement
usage () {
	echo -e "\nLaTexCompiler v0.0.4"
	echo -e "Written by KDTS - last revision on 13. 05. 2015\n"
	echo -e "DESCRIPTION $0"
	echo -e "\tis a simple bash-script to compile a latex-document and generate a pdf-document using \"pdflatex\"."
	echo -e "\tIt can run a gnuplot-file to plot images that are inserted in the latex-document."
	echo -e "\tIt can run \"biber\" to insert references from a biblatex-document in the latex-document."
	echo -e "\tIt can generate the index-page for the pdf-document."
	echo -e "\tIt can compile a latex-document that includes SVG images."
	echo -e "\tIt clears by default unnecessary documents like *(.aux, .out, .toc, .bcf ....).\n"
	echo -e "SIMPLICITY"
	echo -e "\t 1) open the script to edit the CONFIGURATION PART (lines 14 - 39)"
	echo -e "\t 2) follow the instractions to enter the name (and location path)  of your documents"
	echo -e "\t 3) save the changes"
	echo -e "\t NOW YOU CAN JUST CALL $0\n"
	echo -e "USAGE EXAMPLES"
	echo -e "\t$0 -t texDocument.tex"
	echo -e "\t  -------> Generate pdf-document"	
	echo -e "\t$0 -t /path/to/texDocument.tex"
	echo -e "\t  -------> Generate pdf-document if tex-file is not located in the same directory as this script"
	echo -e "\t$0 -p plot.tpl"
	echo -e "\t  -------> Run only gnuplot file"
	echo -e "\t$0 -t texDocument.tex -p plot.tpl"
	echo -e "\t  -------> Run gnuplot file and generate pdf-document including images"
	echo -e "\t$0 -t texDocument.tex -b biblatexDocument.bib"
	echo -e "\t  -------> Generate pdf-document and insert references"
	echo -e "\t$0 -t texDocument.tex -b biblatexDocument.bib -p plot.tpl --svg --index -c yes"
	echo -e "\t  -------> Combining all options\n"
	echo -e "OPTIONS"
	echo -e "\tCommand     alternative  Command  Description"
	echo -e "\t-h          --help                Display this help"
	echo -e "\t-t <file>   --texfile <file>      Compile latex document --  <file> or </path/to/file>"
	echo -e "\t-p <file>   --plotfile <file>     Compile gnuplot-(frame)file to plot images for the latex document --  <file> or </path/to/file>"
	echo -e "\t-b <file>   --bibfile <file>      Bind biblatex-file to integrate references --  <file> or </path/to/file>"
	echo -e "\t-s          --svg                 Compile tex-file regarding SVG images"
	echo -e "\t-i          --index               Make index page"
	echo -e "\t-c [yes|no] --clear [yes|no]      Remove unnecessary like *(.aux, .out, .toc, .bcf ....)     -- by default yes\n"
}

#---------------------- get name of files involed to compile the latex document
set -- `getopt -n$0 -u -a --longoptions="help texfile: plotfile: bibfile: clear: svg index" "h" "p:" "b:" "t:" "c:" "s" "i" "$@"` || usage

while [ $# -gt 0 ]
do
	case "$1" in
	-h | --help)		usage 
	;;
	-t | --texfile)		texFile=$2; DO_TEX="yes"; shift
	;;
	-p | --plotfile)	plotFile=$2; DO_PLOT="yes"; shift
	;;
	-b | --bibfile) 	bibFile=$2; DO_BIB="yes"; shift
	;;
	-c | --clear) 		CLEAR=$2; shift
	;;
	-s | --svg) 		SVG="yes"
	;;
	-i | --index) 		MAKEINDEX="yes"
	;;
	esac
    shift
done

#---------------------- check if tex-file exists
if [ -f "$texFile" ] 
then
	TEXFILE=$texFile
    fileExists_tex="yes"
elif [ -f "$TEX_FILE" ] 
then
	TEXFILE=$TEX_FILE
    fileExists_tex="yes"
else
	TEXFILE=""
	fileExists_tex="no" 
fi;

#---------------------- check if gnuplot-file exists
if [ -f "$plotFile" ]
then
	PLOTFILE=$plotFile
    fileExists_gnuplot="yes"
elif [ -f "$PLOT_FILE" ]
then
	PLOTFILE=$PLOT_FILE
    fileExists_gnuplot="yes" 
else
	PLOTFILE=""
	fileExists_gnuplot="no" 
fi

#---------------------- check if bib-file exists
if [ -f "$bibFile" ] 
then
	BIBFILE=$bibFile
    fileExists_bib="yes" 
elif [ -f "$BIB_FILE" ] 
then
	BIBFILE=$BIB_FILE
    fileExists_bib="yes" 
else
	BIBFILE=""
	fileExists_bib="no" 
fi

#---------------------- check if unnecessary should be deleted
if [ "$CLEAR" != "no" ] && [ "$CLEAR" != "No" ]  && [ "$CLEAR" != "nO" ] && [ "$CLEAR" != "NO" ] && [ "$CLEAR" != "n" ] && [ "$CLEAR" != "N" ] 
then
	CLEAR="yes"
fi

#---------------------- execute gnuplot if the file exists
if [ "$fileExists_gnuplot" == "yes" ]  
then
	echo -e "\nstarting Gnuplot to execute $PLOTFILE ..."
	gnuplot -persist<<_PLOT_
load "$PLOTFILE"
quit
_PLOT_
	echo -e "\nDone..."
fi

#---------------------- compile tex-file if the file exists
if [ "$fileExists_tex" == "yes" ]  
then
	clear
	echo -e "\ncompiling teX-file to pdf-file using pdflatex-command ...\n"
	if [ "$SVG" == "yes" ] ; then
		pdflatex -interaction=nonstopmode -shell-escape $TEXFILE
	else
		pdflatex $TEXFILE
	fi
fi 

#---------------------- compile bib-file if the file exists
if [ "$fileExists_bib" == "yes" ]  
then
	echo -e "\nbinding bib-file to integrate references using biber ...\n"
	biber "${TEXFILE%.*}"
fi 

#---------------------- build the index on demand
if [ "$MAKEINDEX" == "yes" ] 
then
	if [ "$fileExists_tex" == "yes" ]
	then
		echo -e "\nmaking the index ...\n"
		makeindex "${TEXFILE%.*}" 
	else 
		echo "##########################################################"
		echo -e "\nERROR: In order to create the index page,"
		echo -e "         you should enter the (location and) name the tex-document.\n"
	fi
fi 

#---------------------- recompile tex-file for the second time if the file exists
if [ "$fileExists_tex" == "yes" ]  
then
	echo -e "\nrecompiling teX-file to rebuild the pdf-file ...\n"
	if [ "$SVG" == "yes" ] ; then
		pdflatex -interaction=nonstopmode -shell-escape $TEXFILE
	else
		pdflatex $TEXFILE
	fi
	
fi 

#---------------------- error handling
if [ "$fileExists_tex" != "yes" ]
then
	if [ "$DO_TEX" == "yes" ] || [ "$TEX_FILE" != "" ]
	then
		theFileName=$([ $texFile != "" ] && echo $texFile  || echo $TEX_FILE )
		echo "##########################################################"
		echo -e "\nERROR: the latex file \"$theFileName\" seems not to exists.\n"
		exit 1
	fi

	if [ "$SVG" == "yes" ]
	then
		echo "##########################################################"
		echo -e "\nERROR: In order to compile the tex-document contening SVG images,"
		echo -e "         you should enter the (location and) name the tex-document.\n"
	fi

	if [ "$CLEAR" == "yes" ] 
	then 
		echo "##########################################################"
		echo -e "\nERROR: In order to clear unnecessary files like *(.aux, .log, .out, .toc),"
		echo -e "         you should enter the (location and) name the tex-document AND MAKE SURE IT EXISTS.\n"
		exit 1
	fi
fi


if [ "$fileExists_bib" != "yes" ] && [ "$DO_BIB" == "yes" ] || [ "$fileExists_bib" != "yes" ] && [ "$BIB_FILE" != "" ]
then
	theFileName=$([ $bibFile != "" ] && echo $bibFile  || echo $BIB_FILE )
	echo "##########################################################"
	echo -e "\nERROR: the biblatex file \"$theFileName\" seems not to exists.\n"
	exit 1
fi


if [ "$fileExists_gnuplot" != "yes" ] && [ "$DO_PLOT" == "yes" ] || [ "$fileExists_gnuplot" != "yes" ] && [ "$PLOT_FILE" != "" ]
then
	theFileName=$([ $plotFile != "" ] && echo $plotFile  || echo $PLOT_FILE )
	echo "##########################################################"
	echo -e "\nERROR: the plot .. file \"$theFileName\" seems not to exists.\n"
	exit 1
fi


#---------------------- clear and terminate
if [ -f "${TEXFILE%.*}.pdf" ] 
then
	if [ "$CLEAR" == "yes" ] 
	then
		echo -e "\nclearing *(.aux, .log, .out, .toc, .bcf, .run.*, .blg, .bbl, .idx, .ind, .ilg)-Files"
		if [ -f "${TEXFILE%.*}.aux" ] ; then  rm ${TEXFILE%.*}.aux ; fi
		if [ -f "${TEXFILE%.*}.log" ] ; then  rm ${TEXFILE%.*}.log ; fi
		if [ -f "${TEXFILE%.*}.out" ] ; then  rm ${TEXFILE%.*}.out ; fi
		if [ -f "${TEXFILE%.*}.toc" ] ; then  rm ${TEXFILE%.*}.toc ; fi
		if [ -f "${TEXFILE%.*}.bcf" ] ; then  rm ${TEXFILE%.*}.bcf ; fi
		if [ -f "${TEXFILE%.*}.run.xml" ] ; then  rm ${TEXFILE%.*}.run.* ; fi
		if [ -f "${TEXFILE%.*}.blg" ] ; then  rm ${TEXFILE%.*}.blg ; fi
		if [ -f "${TEXFILE%.*}.ilg" ] ; then  rm ${TEXFILE%.*}.ilg ; fi
	fi
	echo -e "\nDone... \npdf-file created: ${TEXFILE%.*}.pdf (`du -h ${TEXFILE%.*}.pdf|cut -f1` )\n"
	open ${TEXFILE%.*}.pdf
fi



