
suppressPackageStartupMessages({ library(optparse); library(readxl); library(pROC); library(boot); library(dplyr); library(jsonlite) })

opt <- parse_args(OptionParser(option_list=list(
  make_option(c("-i","--input"), type="character", default=NULL),
  make_option(c("-t","--target"), type="character", default="Y"),
  make_option(c("-p","--positive"), type="character", default="1"),
  make_option(c("-s","--sheet"), type="character", default=NULL),
  make_option(c("--kfold"), type="integer", default=10),
  make_option(c("--threshold"), type="double", default=0.5),
  make_option(c("--seed"), type="integer", default=42)
)))

set.seed(opt$seed)
read_any <- function(path, sheet=NULL) { if (grepl("\\.xlsx?$", path, ignore.case=TRUE)) readxl::read_excel(path, sheet=sheet) else read.csv(path, stringsAsFactors=FALSE) }

df <- read_any(opt$input, opt$sheet); if ("ID" %in% names(df)) df$ID <- NULL; df <- na.omit(df)
reg0 <- glm(as.formula(paste(opt$target, "~ 1")), data=df, family=binomial)
reg1 <- glm(as.formula(paste(opt$target, "~ .")), data=df, family=binomial)
forward <- step(reg0, scope=formula(reg1), direction="forward", k=2, trace=0)
backward<- step(reg1, scope=list(lower=formula(reg0), upper=formula(reg1)), direction="backward", k=2, trace=0)

cv_f <- cv.glm(df, forward, K=opt$kfold)$delta[1]
cv_b <- cv.glm(df, backward, K=opt$kfold)$delta[1]

evaluate <- function(model, df, thr=0.5, pos="1") {
  probs <- as.numeric(predict(model, newdata=df, type="response"))
  y <- df[[opt$target]]; if (!is.factor(y)) y <- factor(y); if (!(pos %in% levels(y))) y <- factor(y, levels=c(levels(y), pos))
  pred <- ifelse(probs > thr, pos, setdiff(levels(y), pos)[1]); cm <- table(actual=y, pred=pred)
  acc <- sum(diag(cm))/sum(cm); pos_level <- pos
  tp <- ifelse(!is.na(cm[pos_level,pos_level]), cm[pos_level,pos_level], 0)
  fp <- sum(cm[setdiff(rownames(cm), pos_level), pos_level], na.rm=TRUE)
  fn <- sum(cm[pos_level, setdiff(colnames(cm), pos_level)], na.rm=TRUE)
  prec <- ifelse((tp+fp)==0, NA, tp/(tp+fp)); rec <- ifelse((tp+fn)==0, NA, tp/(tp+fn))
  rocobj <- try(pROC::roc(y, probs, quiet=TRUE), silent=TRUE); auc <- if (inherits(rocobj,"try-error")) NA else as.numeric(pROC::auc(rocobj))
  list(cm=cm, acc=acc, precision=prec, recall=rec, auc=auc)
}

m_f <- evaluate(forward, df, thr=opt$threshold, pos=opt$positive)
m_b <- evaluate(backward, df, thr=opt$threshold, pos=opt$positive)
dir.create("outputs", showWarnings=FALSE)
jsonlite::write_json(list(cv_forward=m_f, cv_backward=m_b, cv_err_forward=cv_f, cv_err_backward=cv_b), path="outputs/metrics.json", auto_unbox=TRUE, pretty=TRUE)
capture.output(summary(forward), file="outputs/summary_forward.txt")
capture.output(summary(backward), file="outputs/summary_backward.txt")
png("outputs/roc_forward.png", width=1000, height=800, res=150); plot(pROC::roc(df[[opt$target]], predict(forward, type='response'), quiet=TRUE), main='ROC — Forward'); dev.off()
png("outputs/roc_backward.png", width=1000, height=800, res=150); plot(pROC::roc(df[[opt$target]], predict(backward, type='response'), quiet=TRUE), main='ROC — Backward'); dev.off()
