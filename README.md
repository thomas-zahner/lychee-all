A collection of ideas, programs and scripts to make [lychee](https://github.com/lycheeverse/lychee/) compatible with additional file formats.

Out of the box lychee supports HTML, Markdown and plain text formats.
More precisely, HTML files are parsed as HTML5 with the use of the [html5ever](https://github.com/servo/html5ever) parser
and Markdown files are treated as [CommonMark](https://commonmark.org/) with the use of [pulldown-cmark](https://github.com/pulldown-cmark/pulldown-cmark/).

For any other file format lychee falls back to a "plain text" mode.
This means that [linkify](https://github.com/robinst/linkify) attempts to extract URLs on a best-effort basis.
If invalid UTF-8 characters are encountered the input file is skipped.

# Preprocess files

lychee allows file preprocessing with the `--preprocess` flag.
For each input file the command specified with `--preprocess` is invoked instead of reading the input file directly.
In the following there are examples how to preprocess common file formats.
In most cases it's necessary to create a helper script for preprocessing,
as no parameters can be supplied from the CLI directly.

```bash
lychee files/* --preprocess ./script.sh
```

Take a look at [script.sh](./script.sh) to see how this is done.

# Converting file formats

## epub, docx, odt, xlsx, ipynb

pandoc is a powerful conversion tool which allows us to convert many file types into HTML.

```bash
pandoc "$1" --to=html --wrap=none --markdown-headings=atx
```

## odp, pptx, ods, xlsx

LibreOffice can convert documents to various formats.
Unfortunately, it does not support printing the result to stdout directly as of 2025,
as the `--cat` option is not compatible with `--convert-to`.
This makes usage a bit clumsy.
Additionally, LibreOffice includes URLs in the head which we discard with `sed`.

```bash
libreoffice --headless --convert-to html "$1" --outdir /tmp
file=$(basename "$1")
file="/tmp/${file%.*}.html"
sed '/<body/,$!d' "$file" # discard content before body which contains libreoffice URLs
rm "$file"
```

## AsciiDoc

Using [asciidoctor](https://docs.asciidoctor.org/) we can convert AsciiDoc to HTML.
This ensures that URLs are properly interpreted.

```bash
asciidoctor -a stylesheet! "$1" -o -
```

## PDF

Using poppler-utils we can convert PDFs to HTML:

```bash
pdftohtml -i -s -stdout "$1"

# or to text
pdftotext "$1" -
```

Alternatively, pdftk can be used to extract URI directives from PDFs.
Source: https://unix.stackexchange.com/a/531883

```bash
pdftk "$1" output - uncompress | grep -aPo '/URI *\(\K[^)]*'
```

## CSV

Although, CSV seems like a simple data format lychee cannot understand value separators.

```
url,name
https://github.com/lycheeverse/lychee,Hello there
```

In the above example lychee might mistakingly detect `https://github.com/lycheeverse/lychee,Hello` as a URL.
CSV separators can be customised and there is no way for lychee to know what separators are used.
Because of that, it's the user's responsibility to transform CSV into a format lychee can understand.

### csvtk

[csvtk](https://github.com/shenwei356/csvtk) is a toolkit to work with CSV data.
Apart from many advanced features, it allows us to convert and pretty-print CSV.
One possible way to transform the data is:

```bash
csvtk csv2json "$1"
```
