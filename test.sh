#! /usr/bin/env nix-shell
#! nix-shell -p bash poppler-utils pdftk pandoc csvtk asciidoctor -i bash --pure

./lychee files/* --pre ./script.sh --dump $1
