#!/bin/env python3

import sys, glob, os, collections, math, scipy.stats

print('Retrieve frequencies per site')
lexicon_sites = {}
for filename in glob.glob("Donnees/Textes/*.words.txt"):
	sitename = os.path.basename(filename)[:-len('.words.txt')]
	print('- ', sitename)
	lexicon_sites[sitename] = collections.Counter(open(filename).read().split(' '))

print('Selecting common words')
words = set.intersection(*[set([k for k in lexicon_sites[s].keys() if len(k)]) for s in lexicon_sites])
print('=>', len(words), 'uniq words')

print('Oversampling sites')
sites_freqs = {}
for s in lexicon_sites:
	sites_freqs[s] = sum(lexicon_sites[s].values())
sites_freqs_max = max(sites_freqs.values())
for s in lexicon_sites:
	ratio = sites_freqs_max/sites_freqs[s]
	for w in words:
		lexicon_sites[s][w] = int(ratio*lexicon_sites[s][w])

print('Building lexicon over all sites')
lexicon_all = {w: sum([lexicon_sites[s][w] for s in lexicon_sites]) for w in words if len(w)}
total = sum(lexicon_all.values())

print('Computing specificities')
specneg = False
lexicon_specs = {}
for s in lexicon_sites:
	lexicon_specs[s] = {}
	print('Site ', s, '(', sites_freqs[s], ' tokens), showing 20 most specifics')
	for w in words:
		proba = -1
		sign = 1
		freq_exp = lexicon_all[w]*sites_freqs_max/total
		if lexicon_sites[s][w] > freq_exp:
			proba = scipy.stats.hypergeom.sf(lexicon_sites[s][w], total, lexicon_all[w], sites_freqs_max)
			sign = -1
		elif specneg:
			proba = scipy.stats.hypergeom.cdf(lexicon_sites[s][w], total, lexicon_all[w], sites_freqs_max)
		spec = 0
		if proba > 0:
			indicespec = math.log(proba, 10)
			indicespec *= sign
			# print(w, lexicon_sites[s][w], lexicon_all[w], freq_exp)
			lexicon_specs[s][w] = indicespec
		# else:
		# 	indicespec = scipy.stats.hypergeom.logpmf(lexicon_sites[s][w], total, lexicon_all[w], site_total)/math.log(10)
		# 	print('*** error computing specificity for', w, proba, '***')
	for w, spec in sorted(lexicon_specs[s].items(), key=lambda x: -abs(x[1]))[:20]:
		print(' - word:', w, '(specificity:', spec, 'site:', lexicon_sites[s][w], ', total:', lexicon_all[w], ')')