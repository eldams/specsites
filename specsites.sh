#!/bin/bash

treetagger=~/Applications/TreeTagger/cmd/tree-tagger-english

function scrap {
	echo "Scrapping"
	mkdir -p data/sites
	rm -f data/sites/wget.log
	for site in $sites; do
		echo "- $site"
		wget -r -U bash -P data/sites -r $site >> data/sites/wget.log 2>&1
	done
	find . -regex '.* .*' -delete
}

function extracttxt {
	echo "Extracting"
	mkdir -p data/texts
	for site in $(find data/sites -type d -depth 1); do
		sitename=$(basename $site | sed 's/www.//' | sed 's/.fr//')
		echo "- $sitename"
		find $site -type f | grep -Ev "\.(css|png|gif|jpg|js)" | xargs grep -ilI "html" | xargs cat | tr '\n\r\t' ' ' |
			perl -pe 's#<(head|link|script|code|style) [^>]*>.*?</\1>##gi' | # Nodes to be removed (content also removed)
			perl -pe 's#</?(a|strong|em|b|i|span|img|big|small|abbr|acronym|q|font).*?>##gi' | # Tags to be removed (keep content)
			perl -pe 's/<[^>]*>/\n/g' | # Remaining tags as sentence separators
			python3 -c 'import html, sys; [print(html.unescape(l), end="") for l in sys.stdin]' |
			grep -v '{' | grep -E '( [a-z]+.*){5}' |
			sed 's/  */ /g' | sed 's/^ *//' | sed 's/ *$//' |
			sort | uniq -c | sort -gr > data/texts/$sitename.sentences.txt
	done
}

function preprocess {
	echo "Preprocessing"
	for txt in data/texts/*.sentences.txt; do
		sitename=$(basename $txt .sentences.txt)
		echo "- $sitename"
		cat $txt | sed 's/^ *[0-9]* *//g' |
			$treetagger 2>/dev/null | grep -E '(NNS?|VB(D|G|N|P|Z))|JJ)' | grep -v -E '<unknown>' |
			cut -f 3 | tr '[:upper:]' '[:lower:]' | tr '\n' ' ' > data/texts/$sitename.lemmas.txt
	done
}

function specificities {
	echo "Computing specificities"
	python3 calspecs.py > data/calspecs.log
	cat data/calspecs.log | grep -E '^Site| - word' | sed -E 's#Site *([^ ]*) *. *([0-9]*).*#<li><b>\1</b> (\2 lemmas) :#' | sed -E 's# - word: ([^ ]*) .specificity: ([0-9]*\.[0-9]{0,2}).*#<em>\1</em> (\2)#' | tr '\n' ',' | perl -pe 's#,<li>#</li>\n<li>#g' | sed 's#,$#</li>#' | sed 's/:,/: /' | sed 's/,/, /g' > data/calspecs.html
}

sites=$(cat sites.lst)
# scrap
# extracttxt
# preprocess
specificities
cat calspecs.log
