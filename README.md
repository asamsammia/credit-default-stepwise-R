# Credit Default (UCI) — Stepwise Logistic (R)

Clean R version of your **final** project: forward & backward stepwise **logistic regression** with 10‑fold CV,
ROC/AUC, and confusion matrix. Includes a demo run so CI passes without the dataset.

**Reported results (from your final report):**
- Confusion-matrix precision (Yes): ~**72%**
- Recall (Yes): ~**24%**
- ROC AUC: **0.724**

## Quickstart
```r
# Install packages
pkgs <- c("optparse","readxl","pROC","boot","dplyr")
to_install <- pkgs[!pkgs %in% rownames(installed.packages())]
if (length(to_install)) install.packages(to_install, repos="https://cloud.r-project.org")

# Demo run (synthetic data)
Rscript scripts/logit_stepwise_cv.R --demo

# Real data (CSV)
Rscript scripts/logit_stepwise_cv.R       --input "data/default_of_credit_card_clients.csv"       --target Y --positive 1 --kfold 10 --threshold 0.5
```

## Files
- `scripts/logit_stepwise_cv.R` — stepwise (AIC), CV, ROC/AUC, confusion
- `.github/workflows/r-ci.yml` — CI runs the `--demo` pipeline
- `outputs/` — artifacts (gitignored)
