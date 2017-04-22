# specsites

## Short description

This is a beta version of a quite simple a straightforward software that does compute "specificities" for text within websites. In  short: it extracts vocabulary specific sub-corpora within a corpus using [hypergeometric distribution](https://en.wikipedia.org/wiki/Hypergeometric_distribution).

Current version, as an example, compares Republican's (gop.com) vs Democrat's websites (takes 1 day - gop.com is quite big):

- **gop.com**: (1267342 lemmas) : *deficit* (287.02), *insurance* (285.96), *president* (280.52), *year* (263.09), *speech* (244.38), *premium* (236.14), *thing* (234.38), *tell* (230.46), *give* (224.32), *administration* (221.76), *concern* (221.40), *official* (219.76), *estimate* (211.88), *cnn* (206.11), *month* (200.40), *deal* (185.93), *come* (179.60), *cost* (178.30), *nomination* (175.86), *aide* (174.01)
- **democrats.org** (28332 lemmas) : *intern* (316.15), *registration* (293.54), *resource* (285.62), *voting* (285.47), *support* (283.40), *member* (281.62), *country* (260.84), *expand* (238.00), *democracy* (229.78), *family* (226.82), *gender* (226.59), *immigrant* (225.35), *promote* (219.12), *retirement* (217.55), *party* (216.84), *election* (211.32), *voter* (208.85), *violence* (204.64), *equality* (199.70), *development* (194.99)

## Requirements

- [TreeTagger](http://www.cis.uni-muenchen.de/~schmid/tools/TreeTagger)
- python3 with scipy

## How-to

- Edit sites.lst
- Configure TreeTagger command in `specsites.sh`
- Execute `bash specsites.sh`

## Short description

Main steps of the script are

- Download of websites (`wget`)
- Find texts from sites (remove code / tags using ad-hoc regular expressions)
- Reduce redundancies accross sites: each extracted sentence should only appear once
- Lemmatizing sentences and filter POS: nouns, verbs, adverbs (TreeTagger)
- Select vocabulary that intersect all sites
- Oversample frequencies according to the largest website
- Compute specificities (see below) and select 20 most specific terms for each website, displayed as a HTML list

## Specificities computation

Specificity has been proposed by [Lafon (1980)](http://www.persee.fr/doc/mots_0243-6450_1980_num_1_1_1008) and is a computation that highlights terms which are statistically predominant within a subpart of a given corpus. The goal is quite similar to a chi-squared test. For a given term, the score is the logarithm of the cumulative distribution function for the [Hypergeometric distribution](https://en.wikipedia.org/wiki/Hypergeometric_distribution), where parameters are: the size of the entire corpus, the frequency of the word, the size of the subcorpus, and the frequency of the word in that subcorpus. In short, it gives a high score for terms which are over-represented in the part given their frequencies in the entire corpus.
