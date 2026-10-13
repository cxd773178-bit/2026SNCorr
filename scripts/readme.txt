Code and Data Overview

Last updated: 15 September 2026

Execution Order

1. 0_preprocessing/0.i_import_data.R loads and preprocesses the data.
2. 1_maincode/1.1_RSA_main.Rmd runs the main analyses and automatically sources 1.0_RDM_helpers.R.
3. Scripts 99.1–99.4 in 99_visualization/ generate the figures and related outputs.

The data are collected from the 2023 Finance cohort at East China Normal University. The post_final.Rdata dataset contains 113 participants identified by anonymized node_id values. Each of the six social networks contains 127 nodes.

For questions regarding the data, code, or analyses, please contact Xidan Cao (202621061002@mail.bnu.edu.cn) and Jiajie Chen (jchen2000@uchicago.edu).
