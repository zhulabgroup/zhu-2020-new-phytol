# read and plot ForC data
library(tidyverse)

forc_df <- read_csv("data/ForC/ForC_simplified.csv") %>%
  mutate(stand.age = as.numeric(stand.age)) %>%
  filter(
    variable.name == "biomass_ag",
    is.numeric(stand.age),
    !is.na(stand.age),
    stand.age < 999,
    stand.age > 0
  ) %>%
  dplyr::select(id = measurement.ID, agb = mean, stand.age)

# scatter plot
forc_gg <- ggplot(forc_df, aes(stand.age, agb)) +
  geom_point(alpha = .2) +
  labs(x = "Stand age (yr)", y = expression("Aboveground biomass (Mg" ~ C ~ ha^-1 * ")"))
forc_gg

# fit Monod model
monod_mod <- nls(agb ~ SSmicmen(stand.age, mu, k), data = forc_df)
coef(monod_mod)

stand.age_vec <- seq(
  from = 0, to = max(forc_df$stand.age),
  length.out = 500
)
monod_df <- tibble(
  stand.age = stand.age_vec,
  agb = predict(monod_mod,
    newdata = data.frame(stand.age = stand.age_vec)
  )
)

forc_gg +
  geom_line(data = monod_df, aes(stand.age, agb), col = "red", lwd = 2)
ggsave("docs/forc-monod.png", width = 10, height = 6.18)
