# Credit Default (UCI) — Stepwise Logistic (R)

Final project repo with your dataset included in `data/`.

## Quickstart
```r
# install dependencies
pkgs <- c("optparse","readxl","pROC","boot","dplyr")
to_install <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(to_install)) install.packages(to_install, repos="https://cloud.r-project.org")

# run with the included CSV
Rscript scripts/logit_stepwise_cv.R       --input "data/default_of_credit_card_clients.csv"       --target Y --positive 1 --kfold 10 --threshold 0.5
```

Outputs (ROC plots, metrics, confusion) will be written to `outputs/`.
