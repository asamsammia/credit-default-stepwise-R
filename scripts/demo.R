# Demo: generate a small synthetic dataset and save to outputs/demo_data.csv
dir.create("outputs", showWarnings = FALSE, recursive = TRUE)

set.seed(0)
n <- 2000
x1 <- rnorm(n); x2 <- rnorm(n); x3 <- rbinom(n, 1, 0.3)
lin <- -0.5 + 1.2*x1 - 0.8*x2 + 0.7*x3
prob <- 1/(1+exp(-lin))
Y <- rbinom(n, 1, prob)
df <- data.frame(Y=Y, x1=x1, x2=x2, x3=x3, check.names = FALSE)

write.csv(df, file = file.path("outputs", "demo_data.csv"), row.names = FALSE)
message("Wrote outputs/demo_data.csv")
