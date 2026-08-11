###############################################################################
# COMPLETE PROJECT DEMONSTRATION
# Data Analysis in R workshop
#
# Open example_project.Rproj before running this script.
# Run the script section by section from top to bottom.
###############################################################################

# 1. Load packages ---------------------------------------------------------

library(tidyverse)
library(readxl)


# 2. Import and inspect ----------------------------------------------------

ljubljana_raw <- read_xlsx(
  path = "data/precipitation_ljubljana.xlsx",
  sheet = "Data Ljubljana"
)

glimpse(ljubljana_raw)
head(ljubljana_raw)


# 3. Select, rename, and prepare ------------------------------------------

ljubljana_clean <- ljubljana_raw %>%
  select(Year, Month, P, T, RH, d18O, d2H) %>%
  rename(
    year = Year,
    month = Month,
    precipitation_mm = P,
    temperature_c = T,
    relative_humidity = RH,
    d18o = d18O,
    d2h = d2H
  ) %>%
  mutate(
    date = lubridate::make_date(year, month, 1)
  )

isotope_data <- ljubljana_clean %>%
  filter(!is.na(d18o), !is.na(d2h))

glimpse(isotope_data)


# 4. Group and summarise --------------------------------------------------

annual_summary <- ljubljana_clean %>%
  group_by(year) %>%
  summarise(
    months_with_isotopes = sum(!is.na(d18o) & !is.na(d2h)),
    mean_d18o = mean(d18o, na.rm = TRUE),
    mean_d2h = mean(d2h, na.rm = TRUE),
    annual_precipitation_mm = sum(precipitation_mm, na.rm = TRUE),
    .groups = "drop"
  )

head(annual_summary)


# 5. Reshape into tidy long form -----------------------------------------

isotopes_long <- isotope_data %>%
  select(date, d18o, d2h) %>%
  pivot_longer(
    cols = c(d18o, d2h),
    names_to = "isotope",
    values_to = "isotope_value"
  )

head(isotopes_long)


# 6. Visualise the data ---------------------------------------------------

isotope_time_plot <- isotopes_long %>%
  ggplot(aes(x = date, y = isotope_value)) +
  geom_line(color = "#2C7FB8", linewidth = 0.5) +
  facet_wrap(~ isotope, ncol = 1, scales = "free_y") +
  labs(
    title = "Precipitation isotopes through time",
    x = NULL,
    y = "Isotope value"
  ) +
  theme_minimal()

print(isotope_time_plot)

isotope_relationship_plot <- isotope_data %>%
  ggplot(aes(x = d18o, y = d2h)) +
  geom_point(alpha = 0.55, color = "#2C7FB8") +
  geom_smooth(method = "lm", se = FALSE, color = "#D95F0E") +
  labs(
    title = "Relationship between d18O and d2H",
    x = "d18O",
    y = "d2H"
  ) +
  theme_minimal()

print(isotope_relationship_plot)


# 7. Fit a simple linear model -------------------------------------------

isotope_model <- lm(d2h ~ d18o, data = isotope_data)
summary(isotope_model)


# 8. Save reusable outputs ------------------------------------------------

write_csv(
  annual_summary,
  "outputs/annual_isotope_summary.csv"
)

ggsave(
  filename = "outputs/isotopes_through_time.png",
  plot = isotope_time_plot,
  width = 8,
  height = 6,
  dpi = 300
)

ggsave(
  filename = "outputs/isotope_relationship.png",
  plot = isotope_relationship_plot,
  width = 7,
  height = 5,
  dpi = 300
)
