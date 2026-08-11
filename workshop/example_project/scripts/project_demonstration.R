###############################################################################
# DATA ANALYSIS AND VISUALIZATION for JSI-O2 course, "Data analysis in R"
# CODE AUTHOR: JAN GAČNIK, August 2026
# R version: 4.6
###############################################################################

# Loads needed libraries
library("tidyverse")
library("readxl")
library("janitor")

# Let's take a look at the data after reading it into RStudio:
ljubljana_data_raw <- read_xlsx(path = "data/precipitation_ljubljana.xlsx", sheet = "Data Ljubljana")
View(ljubljana_data_raw)

# Plenty columns and their names are not clean, let's clean up col names and select what we actually need
ljubljana_data_clean <- ljubljana_data_raw %>%
  clean_names() %>%
  select(year, month, d2h, d18o)
View(ljubljana_data_clean)

# Then, we can take our clean data and filter out rows with NA for d2H and d18O
# Also, we can add a year-month date format, which will be needed for the plot
ljubljana_data_filtered <- ljubljana_data_clean %>%
  filter(is.na(d2h) == FALSE & is.na(d18o) == FALSE) %>%
  mutate(date = make_date(year, month)) # This makes a Date variable from "year" and "month" variables
View(ljubljana_data_filtered)

# We can look at how the data looks by plotting it, "d2h" and "d18o" through time:
  # d2H
ggplot(data = ljubljana_data_filtered,
       mapping = aes(x = date, y = d2h)) +
  geom_line()

  # d18O
ggplot(data = ljubljana_data_filtered,
       mapping = aes(x = date, y = d18o)) +
  geom_line()

# We can also look at a simple d2h versus d18o plot and make a linear regression:
ggplot(data = ljubljana_data_filtered,
       mapping = aes(x = d18o, y = d2h)) +
  geom_point() +
  geom_smooth(method = "lm")

# The last plot is for the whole period, using "ordinary" linear regression,
# also called ordinary least squares (OLS) regression.

  # An appropriate regression would actually be the reduced major axis (RMA) regression
  # or major axis (MA) regression, accounting for variability both in x and y
  # RMA and MA come from the family of "model II" linear regressions.

# Additionally, we are interested if the slopes and intercepts of the d2H vs d18O
# regression are changing with time (Years) or not.

# You can find a package which already does RMA/MA formulations for you,
# such as "lmodel2" package.
# Alternatively, you can write formulas for RMA and MA yourself, using a custom function:
model2_regression <- function(x, y) {
  n <- length(x)
  x_mean <- mean(x)
  y_mean <- mean(y)
  sum_x <- sum(x)
  sum_y <- sum(y)
  sum_x2 <- sum(x^2)
  sum_y2 <- sum(y^2)
  sum_u2 <- sum((x - x_mean)^2)
  sum_v2 <- sum((y - y_mean)^2)
  sum_uv <- sum((x - x_mean) * (y - y_mean))
  slope_RMA <- sqrt((sum_y2 - sum_y^2/n) / (sum_x2 - sum_x^2/n))
  intercept_RMA <- y_mean - slope_RMA * x_mean
  error_slope_RMA <- sqrt( ((sum((y - (slope_RMA * x + intercept_RMA))^2))/(n - 2)) / sum((x - x_mean)^2) )
  error_intercept_RMA <- error_slope_RMA * sqrt(sum_x2 / n)
  slope_MA <- (sum_v2 - sum_u2 + sqrt((sum_v2 - sum_u2)^2 + 4 * ((sum_uv)^2))) / (2 * sum_uv)
  intercept_MA <- y_mean - slope_MA * x_mean
  error_slope_MA <- sqrt( ((sum((y - (slope_MA * x + intercept_MA))^2))/(n - 2)) / sum((x - x_mean)^2) )
  error_intercept_MA <- error_slope_MA * sqrt(sum_x2 / n)
  pearson_r = cor(x, y, method = "pearson")
  return(list(slopes = list(MA = slope_MA, RMA = slope_RMA),
              errors_slopes = list(MA = error_slope_MA, RMA = error_slope_RMA),
              intercepts = list(MA = intercept_MA, RMA = intercept_RMA),
              errors_intercepts = list(MA = error_intercept_MA, RMA = error_intercept_RMA),
              pearson_r = pearson_r))
}

# Using our custom function, we can compute our RMA/MA the following way:
regressions <- model2_regression(ljubljana_data_filtered$d18o, ljubljana_data_filtered$d2h)

# Slopes and intercepts (their errors too) can be accessed the following way:
regressions$slopes$MA  # MA slope
regressions$intercepts$MA  # MA intercept
regressions$slopes$RMA  # RMA slope
regressions$intercepts$RMA  # RMA intercept

# Let's compare them to the "ordinary" linear regression (OLS) results:
regression_ordinary <- lm(ljubljana_data_filtered$d2h ~ ljubljana_data_filtered$d18o)
regression_ordinary$coefficients[[2]] # OLS slope
regression_ordinary$coefficients[[1]] # OLS intercept

# Now that we know how to compute and access RMA/MA slopes & intercepts,
# we can do it for each year using the following pipeline:
ljubljana_regressions <- ljubljana_data_filtered %>%
  group_by(year) %>% # groups data by year
  summarise(
    slope_MA = model2_regression(x = d18o, y = d2h)$slopes$MA,
    intercept_MA = model2_regression(x = d18o, y = d2h)$intercepts$MA,
    slope_RMA = model2_regression(x = d18o, y = d2h)$slope$RMA,
    intercept_RMA = model2_regression(x = d18o, y = d2h)$intercept$RMA,
    slope_OLS = lm(d2h ~ d18o)$coefficients[[2]],
    intercept_OLS = lm(d2h ~ d18o)$coefficients[[1]]
    )
View(ljubljana_regressions)

# Let's also roung the numbers for better viewability
ljubljana_regressions_rounded <- ljubljana_regressions %>%
  mutate(across(.cols = -year, ~ round(x = .x, digits = 2)))
view(ljubljana_regressions_rounded)

# Now we can plot how the slopes are changing with time, for example for MA slopes:
ggplot(data = ljubljana_regressions,
       mapping = aes(x = year, y = slope_MA)) +
  geom_line() +
  geom_smooth(method = "lm")

# We can also test the statistical significance of the decreasing/increasing trend,
# by using a Mann-Kendall test, which can be found in the "trend" package:
install.packages("trend")
library(trend)

mk.test(ljubljana_regressions$slope_MA, alternative = "two.sided") # Test for any monotonic trend
mk.test(ljubljana_regressions$slope_MA, alternative = "less") # Test for a signif. decreasing trend
mk.test(ljubljana_regressions$slope_MA, alternative = "greater") # Test for a signif. increasing trend

# Based on our analysis, we can conclude that in Ljubljana, the slopes of precipitation isotope plots
# are becoming smaller with time, with 99.9% confidence.

# For hydrology, we combined this analysis with trends for other relevant parameters
# such as temperature, humidity, moisture sources, etc., and found that rising temperatures
# which increase evaporative processes and promote moisture recycling are responsible for the observed trend
