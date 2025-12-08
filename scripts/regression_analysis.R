library(readr)
library(dplyr)

blockfaces <- read_csv("blockface_regression_dataset_2025.csv")

sjsu_blue <- "#0055A2"
sjsu_gold <- "#E5A823"
sjsu_gray <- "#939597"
sjsu_darkgray <- "#53565A"

# Histograms side by side
par(mfrow = c(1, 2))
hist(blockfaces$citation_rate_per_meter,
     main = "Distribution of Citation Rate per Meter",
     xlab = "Citation Rate per Meter",
     col = sjsu_blue,
     border = "white")
hist(blockfaces$log_rate,
     main = "log(citation_rate_per_meter + 1)",
     xlab = "log(citation_rate_per_meter + 1)",
     col = sjsu_gold,
     border = "white")

# Scatter plots side by side
par(mfrow = c(1, 2))
plot(
  blockfaces$meter_count,
  blockfaces$citation_rate_per_meter,
  col = sjsu_blue,
  pch = 16,
  cex = 0.8,
  xlab = "Meter Density (meters per blockface)",
  ylab = "Citation Rate per Meter",
  main = "Citation Rate vs. Meter Density"
)
plot(
  blockfaces$meter_count,
  blockfaces$log_rate,
  col = sjsu_blue,
  pch = 16,
  cex = 0.8,
  xlab = "Meter Density (meters per blockface)",
  ylab = "log(Citation Rate per Meter + 1)",
  main = "log(Citation Rate per Meter + 1) vs. Meter Density"
)