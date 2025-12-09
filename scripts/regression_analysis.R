library(readr)
library(dplyr)

blockfaces <- read_csv("data/blockface_regression_dataset_2025.csv", show_col_types = FALSE)
log_meter_density <- log(blockfaces$meter_count)

sjsu_blue <- "#0055A2"
sjsu_gold <- "#E5A823"
sjsu_gray <- "#939597"
sjsu_darkgray <- "#53565A"

# Histograms side by side
par(mfrow = c(1, 2))
hist(
  blockfaces$citation_rate_per_meter,
  main = "Distribution of Citation Rate per Meter",
  xlab = "Citation Rate per Meter",
  col = sjsu_blue,
  border = "white"
)
hist(
  blockfaces$log_rate,
  main = "log(citation_rate_per_meter + 1)",
  xlab = "log(citation_rate_per_meter + 1)",
  col = sjsu_gold,
  border = "white"
)

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
  col = sjsu_gold,
  pch = 16,
  cex = 0.8,
  xlab = "Meter Density (meters per blockface)",
  ylab = "log(Citation Rate per Meter + 1)",
  main = "log(Citation Rate per Meter + 1) vs. Meter Density"
)

# Cap color distribution
par(mfrow = c(1, 2))

cap_color_counts <- table(blockfaces$cap_color_majority)

bar_midpoints_cap <- barplot(
  cap_color_counts,
  col = sjsu_blue,
  border = "white",
  main = "Majority Cap Color",
  ylab = "Count",
  las = 2,
  ylim = c(0, max(cap_color_counts) * 1.1) 
)
text(
  x = bar_midpoints_cap, 
  y = cap_color_counts, 
  labels = cap_color_counts, 
  pos = 3
)

district_counts <- table(blockfaces$supervisor_district)
bar_midpoints_district <- barplot(
  district_counts,
  col = sjsu_blue,
  border = "white",
  main = "Supervisor District Counts",
  xlab = "District Number",
  ylab = "Count",
  ylim = c(0, max(district_counts) * 1.1) 
)
text(
  x = bar_midpoints_district, 
  y = district_counts, 
  labels = district_counts, 
  pos = 3
)

# Histograms side by side
par(mfrow = c(1, 2))
hist(
  blockfaces$meter_count,
  main = "Distribution of Meter Count",
  xlab = "Meter Count",
  col = sjsu_blue,
  border = "white"
)
hist(
  log_meter_density,
  main = "log(meter_count)",
  xlab = "log(meter_count)",
  col = sjsu_gold,
  border = "white"
)
