# Remake Figure 1 using plot functions in R, 
# assuming Monod growth functions. Use ForC 
# database only to inform reasonable parameters.

# First run 10-explore-forc.R

# Coefs from ForC global database:
#       mu         k 
# 929.2607 1008.9830 

# Figure 1a
# For illustrative purposes, assume that the best-fit 
# Monod curve for ForC simplified data can be described
# as an additive function between enhanced growth and
# regrowth components. Furthermore, assume that the 
# enhanced growth component increases linearly over 
# stand age. 
monod_df_additive <- tibble(
  stand.age = stand.age_vec,
  total = predict(monod_mod,
                  newdata = data.frame(stand.age = stand.age_vec)),
  regrowth_component = stand.age_vec * 0.07,
  enhanced_component = total - regrowth_component
)

fig_1a <- 
  ggplot(monod_df_additive, aes(x=stand.age)) +
  geom_line(aes(y=enhanced_component), lty=2) +
  geom_line(aes(y=regrowth_component), lty=2) +
  geom_line(aes(y=total), col="red", lwd=2) +
  xlab("Stand age") +
  ylab("Aboveground biomass") +
  theme_classic() +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=16))

fig_1a_labels <- tibble(
  x = rep(max(monod_df_additive$stand.age), 3),
  y = c(max(monod_df_additive$total),
        max(monod_df_additive$regrowth_component),
        max(monod_df_additive$enhanced_component)-20),
  labels = c("Total", "Regrowth", "Enhanced\ngrowth"),
  col = c("red", "black", "black")
)
fig_1a +
  geom_text(data=fig_1a_labels, aes(x=x, y=y, label=labels, col=col),
            hjust=0, nudge_x=10, size=(5/14)*12) +
  scale_colour_manual(values=c("black","red")) +
  guides(col=FALSE) +
  expand_limits(x=fig_1a_labels$x + 150, y=fig_1a_labels$y)

ggsave('figs/fig1_a.png', width = 5, height = 3.2)


# Figure 1b
# For illustrative purposes, assume that the best-fit 
# Monod curve for ForC simplified data is one of
# several Monod curves that could be fit. Monod
# parameters mu and k are adjusted to fit other curves.
monod_df_hierarchical <- tibble(
  stand.age = stand.age_vec,
  curve1 = SSmicmen(stand.age, 600, 300), # lower mu, lower k
  curve2 = SSmicmen(stand.age, 1100, 1010), # higher mu
  curve0 = predict(monod_mod, # 930, 1010 # original
                     newdata = data.frame(stand.age = stand.age_vec)),
  curve3 = SSmicmen(stand.age, 930, 1400), # higher k
)

fig_1b <- 
  ggplot(monod_df_hierarchical, aes(x=stand.age)) +
  geom_line(aes(y=curve1), col="green") +
  geom_line(aes(y=curve0), col="red", lwd=2) +
  geom_line(aes(y=curve2), col="blue") +
  geom_line(aes(y=curve3), col="black") + 
  # geom_line(aes(y=curve4), col="magenta") +
  xlab("Stand age") +
  ylab("Aboveground biomass") +
  theme_classic() +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=16))

fig_1b

fig_1b_labels <- tibble(
  x = rep(max(monod_df_hierarchical$stand.age), 4),
  y = c(max(monod_df_hierarchical$curve0),
        max(monod_df_hierarchical$curve1)+10,
        max(monod_df_hierarchical$curve2),
        max(monod_df_hierarchical$curve3)),
  labels = c("Original", "Low μ, k", "High μ", "High k"),
  col = c("red", "green", "blue", "black")
)
fig_1b +
  geom_text(data=fig_1b_labels, aes(x=x, y=y, label=labels, col=col),
            hjust=0, nudge_x=10, size=(5/14)*12) +
  scale_colour_manual(values=c("black","blue","green","red")) +
  guides(col=FALSE) +
  expand_limits(x=fig_1a_labels$x + 150, y=fig_1a_labels$y)

ggsave('figs/fig1_b.png', width = 5, height = 3.2)
  