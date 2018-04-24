# Code Lookup

**pubmed_xml.sh**

Given a list of PubMed ids saved as a text file (e.g. query_pm.ids), fetch the PubMed xml entries.

```
$ bash pubmed_xml.sh query_pm.ids > query_pm.xml
```

**pmc_xml.sh**

Given a list of PMC ids saved as a text file (e.g. query_pmc.ids), fetch the PMC xml entries.

```
$ bash pmc_xml.sh query_pmc.ids > query_pmc.xml
```

**authorlist_pm.pl**

Pulls out the paper to author list from the PubMed XML files

```
$ perl authorlist_pm.pl query_pm.xml > query_authors_pm.tsv
```

**paperlist_pm.pl**

Pulls out the paper list from the PubMed XML files

```
$ perl paperlist_pm.pl query_pm.xml > query_papers_pm.tsv
```

**bothlist_pmc.pl**

Pulls out the author and paper list from the PMC XML files

```
$ perl bothlist_pmc.pl "." query_papers_pmc.tsv query_authors_pmc.tsv query_pm.xml > query_papers_pm.tsv
```

**mkBarchart.R**

Number of publications by year. Create barchart of number of papers by year. Will generate barcharts of number of publications by year for PubMed and PubMed Central Results. Can pass in a range of years for the x axis.

```
$ Rscript mkBarchart.R query_papers_pm.tsv query_pm.tiff
$ Rscript mkBarchart.R query_papers_pm.tsv query_pm.tiff 1996 2016
```

<img src="https://github.com/j23414/cavatica/blob/master/IMG/Cytoscape-pubmedcounts.png" width="300" alt="Plan"><img src="https://github.com/j23414/cavatica/blob/master/IMG/Cytoscape-full-pubmedcounts.png" width="300" alt="Plan">