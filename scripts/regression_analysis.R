library(readr)
library(dplyr)
library(tidyr)
library(ggplot2)

blockfaces <- read_csv("data/blockface_regression_dataset_2025.csv", show_col_types = FALSE)
blockfaces$log_meter_count <- log(blockfaces$meter_count)

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
  blockfaces$log_meter_count,
  main = "log(meter_count)",
  xlab = "log(meter_count)",
  col = sjsu_gold,
  border = "white"
)

# Scatter plots side by side
par(mfrow = c(1, 2))
plot(
  blockfaces$meter_count,
  blockfaces$log_rate,
  col = sjsu_blue,
  pch = 16,
  cex = 0.8,
  xlab = "Meter Density (meters per blockface)",
  ylab = "log(Citation Rate per Meter + 1)",
  main = "Citation Rate vs. Meter Density"
)
plot(
  blockfaces$log_meter_count,
  blockfaces$log_rate,
  col = sjsu_gold,
  pch = 16,
  cex = 0.8,
  xlab = "log(Meter Density)",
  ylab = "log(Citation Rate per Meter + 1)",
  main = "log(Citation Rate per Meter + 1) vs. log(Meter Density)"
)

# fit models

blockfaces$supervisor_district <- as.factor(blockfaces$supervisor_district)
blockfaces$cap_color_majority <- as.factor(blockfaces$cap_color_majority)

model_1 <- lm(log_rate ~ meter_count + cap_color_majority + supervisor_district, data=blockfaces)
model_2 <- lm(log_rate ~ log_meter_count + cap_color_majority + supervisor_district, data=blockfaces)

# build prediction grid for cap color
grid_cap_col <- blockfaces %>%
  group_by(cap_color_majority) %>%
  summarize(
    min_m = min(meter_count),
    max_m = max(meter_count),
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(meter_count = list(seq(min_m, max_m, length.out = 100))) %>%
  unnest(meter_count) %>%
  mutate(
    log_meter_count = log(meter_count),
    supervisor_district = factor(3, levels = levels(blockfaces$supervisor_district))
  )


grid_cap_col$pred_log_rate <- predict(model_1, newdata = grid_cap_col)

cap_col_plot_1 <- ggplot(blockfaces, aes(x = meter_count, y = log_rate)) +
  geom_point(alpha = 0.5, size = 1, color = sjsu_blue) +
  geom_line(data = grid_cap_col, aes(x = meter_count, y = pred_log_rate), color = "red", size = 1) +
  facet_wrap(~ cap_color_majority) +
  xlab("Meter Density (meters per blockface)") +
  ylab("log(Citation Rate per Meter + 1)") +
  ggtitle("Model 1 Fitted Lines by Cap Color") +
  theme_bw(base_size = 13) + theme(legend.position = "none")

print(cap_col_plot_1)

# build prediction grid for district
grid_district <- blockfaces %>%
  group_by(supervisor_district) %>%
  summarize(
    min_m = min(meter_count),
    max_m = max(meter_count),
    .groups = "drop"
  ) %>%
  rowwise() %>%
  mutate(meter_count = list(seq(min_m, max_m, length.out = 100))) %>%
  unnest(meter_count) %>%
  mutate(
    log_meter_count = log(meter_count),
    cap_color_majority = factor("Grey", levels = levels(blockfaces$cap_color_majority))
  )

grid_district$pred_log_rate <- predict(model_1, newdata = grid_district)

district_plot <- ggplot(blockfaces, aes(x = meter_count, y = log_rate)) +
  geom_point(alpha = 0.5, color = sjsu_blue, size = 1) +
  geom_line(data = grid_district, aes(x = meter_count, y = pred_log_rate), color = "red", size = 1) +
  facet_wrap(~ supervisor_district) +
  xlab("Meter Density (meters per blockface)") +
  ylab("log(Citation Rate per Meter + 1)") +
  ggtitle("Model 1 Fitted Lines by Supervisor District") +
  theme_bw(base_size = 13) + theme(legend.position = "none")

print(district_plot)

par(mfrow = c(2, 2), mar = c(6, 5, 4, 2) + 0.1)

residuals_1 <- residuals(model_1)

# Histogram of residuals
hist(residuals_1,
     main = "Distribution of Residuals (Model 1)",
     xlab = "Residual value",
     col = sjsu_blue,
     border = "white")

# Q-Q plot of residuals
qqnorm(residuals_1,
       main = "Normal Q-Q Plot of Residuals 1 (Model 1)",
       pch = 19,
       col = sjsu_blue)
qqline(residuals_1, lwd = 2)

residuals_2 <- residuals(model_2)

# Histogram of residuals
hist(residuals_2,
     main = "Distribution of Residuals (Model 2)",
     xlab = "Residual value",
     col = sjsu_gold,
     border = "white")

# Q-Q plot of residuals
qqnorm(residuals_2,
       main = "Normal Q-Q Plot of Residuals (Model 2)",
       pch = 19,
       col = sjsu_gold)
qqline(residuals_1, lwd = 2)


#Residuals vs Fitted
fitted_1 <- fitted(model_1)
fitted_2 <- fitted(model_2)
par(mfrow = c(1, 2))
plot(fitted_1, residuals_1,
     col = sjsu_blue,
     main = "Residuals vs Fitted Values (Model 1)",
     xlab = "Fitted Values",
     ylab = "Residuals",
     pch = 16)
abline(h = 0, lty = 2)
plot(fitted_2, residuals_2,
     col = sjsu_gold,
     main = "Residuals vs Fitted Values (Model 2)",
     xlab = "Fitted Values",
     ylab = "Residuals",
     pch = 16)
abline(h = 0, lty = 2)