#!/usr/bin/env bash

case "$1" in
*.pdf)
    exec pdftotext "$1" -
    # Alternatives:
    # exec pdftohtml -s "$1" -stdout
    # exec pdftk "$1" output - uncompress | grep -aPo '/URI *\(\K[^)]*'
    ;;
*.epub|*.odt|*.docx|*.ipynb)
    exec pandoc "$1" --to=html --wrap=none --markdown-headings=atx
    ;;
*.adoc|*.asciidoc)
    asciidoctor -a stylesheet! "$1" -o -
    ;;
*.csv)
    # specify --delimiter if values not delimited by ","
    exec csvtk csv2json "$1"
    ;;
*)
    # identity function, output input without changes
    exec cat
    ;;
esac
