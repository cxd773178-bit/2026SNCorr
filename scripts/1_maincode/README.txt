Main Analysis

This directory contains the code for the IS-RSA analyses reported in the manuscript.
Execution Order

1. 1.0_RDM_helpers.R defines the functions used to construct representational dissimilarity matrices (RDMs). It is sourced automatically by the main analysis script.
2. 1.1_RSA_main.Rmd performs the centrality- and network-distance-based IS-RSA analyses, permutation tests, and Mantel tests.

Data are loaded and preprocessed through ../0_preprocessing/0.i_import_data.R.
