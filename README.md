# SpecSites

This is a beta version of a quite simple a straightforward software that does compute "specificities" for text within websites. In  short: it extracts vocabulary specific sub-corpora within a corpus using [hypergeometric distribution](https://en.wikipedia.org/wiki/Hypergeometric_distribution).

Main steps of the script are

- Download of websites (`wget`)
- Find texts from sites (remove computer code, mainly with regular expressions)
- Eliminating of redundancies accross sites (each sentence should only appear once)
- Lemmatize sentences and filter POS: nousn, verbs, adjectives, adverbs (TreeTagger)
- Select vocabulary that intersect all sites
- Oversample according to the largest website
- Compute specificities and select 20 most specific terms for each website

It requires

- [TreeTagger](http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger)
- python3 with scipy

You may try it bash `specsites.sh`, as an example it does the comparison of Republican's vs Democrat's websites.
