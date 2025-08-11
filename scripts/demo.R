
# Synthetic demo so CI runs green without the dataset
set.seed(0)
n <- 2000; x1 <- rnorm(n); x2 <- rnorm(n); x3 <- rbinom(n,1,0.3)
lin <- -0.5 + 1.2*x1 - 0.8*x2 + 0.7*x3
prob <- 1/(1+exp(-lin)); Y <- rbinom(n, 1, prob)
df <- data.frame(Y=Y, x1=x1, x2=x2, x3=x3)
write.csv(df, "outputs/demo_data.csv", row.names=FALSE)
