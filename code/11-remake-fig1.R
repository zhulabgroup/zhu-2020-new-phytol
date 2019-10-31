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
dropoff_a_x <- c(-100, 0, 0)
dropoff_a_y <- c(500, 500, 50)

monod_df_additive <- tibble(
  stand.age = c(dropoff_a_x, stand.age_vec),
  reduced_regrowth = c(dropoff_a_y, SSmicmen(stand.age_vec, 900, 1000)),
  regrowth = c(dropoff_a_y, SSmicmen(stand.age_vec, 900, 1000)+50),
  enhanced_regrowth = c(dropoff_a_y, SSmicmen(stand.age_vec, 900, 1000)+100)
)

gather(monod_df_additive, key="curve", value="agb", 
       reduced_regrowth:enhanced_regrowth) %>%
  mutate(size = if_else(curve=="regrowth", 2, 1)) ->
  monod_df_additive_long

fig_1a <- 
  ggplot(monod_df_additive_long, aes(x=stand.age, col=curve, y=agb, size=size)) +
  geom_line() +
  scale_colour_manual(name="",
                      labels=c("Enhanced regrowth", "Reduced regrowth", "Regrowth"),
                      values=c("green","red", "black")) +
  scale_size(range=c(1, 3)) +
  xlab("Stand age (yr)") +
  ylab(expression(Aboveground~biomass~(Mg~C~ha^-1))) +
  guides(size=FALSE) +
  theme_classic() +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=16)) +
  theme(legend.justification = c(1, 0), legend.position = c(1, 0),
        legend.box.margin=margin(c(5,5,5,5)), 
        legend.text=element_text(size=11)) +
  expand_limits(y=535) +
  scale_y_continuous(breaks=seq(0,500,by=100)) +
  labs(tag="(a)")

fig_1a

ggsave('figs/fig1_a.png', width = 5, height = 4.1)


# Figure 1b
# For illustrative purposes, assume that the best-fit 
# Monod curve for ForC simplified data is one of
# several Monod curves that could be fit. Monod
# parameters mu and k are adjusted to fit other curves.
dropoff_b_x <- c(-100, 0, 0)
dropoff_b_y <- c(450, 450, 0)

monod_df_hierarchical <- tibble(
  stand.age = c(dropoff_b_x, stand.age_vec),
  curve0 = c(dropoff_b_y, SSmicmen(stand.age_vec, 900, 1000))+50,
  curve1 = c(dropoff_b_y, SSmicmen(stand.age_vec, 600, 300))+50, # lower mu, lower k
  curve2 = c(dropoff_b_y, SSmicmen(stand.age_vec, 1100, 1010))+50, # higher mu
  curve3 = c(dropoff_b_y, SSmicmen(stand.age_vec, 930, 1400))+50 # higher k
)

gather(monod_df_hierarchical, key="curve", value="agb", 
       curve0:curve3) %>%
  mutate(size = if_else(curve=="curve0", 2, 1),
         curve = factor(curve, levels=c("curve3","curve2","curve1","curve0"))) ->
  monod_df_hierarchical_long

fig_1b <- 
  ggplot(monod_df_hierarchical_long, aes(x=stand.age, col=curve, y=agb, size=size)) +
  geom_line() +
  scale_colour_manual(name="",
                      labels=c("Changed recovery rate","Changed mature state","Changed both","Regrowth"),
                      values=c("red","blue","green","black")) +
  scale_size(range=c(1, 3)) +
  xlab("Stand age (yr)") +
  ylab(expression(Aboveground~biomass~(Mg~C~ha^-1))) +
  guides(size=FALSE) +
  theme_classic() +
  theme(axis.text=element_text(size=12),
        axis.title=element_text(size=16)) +
  theme(legend.justification = c(1, 0), legend.position = c(1, 0),
        legend.box.margin=margin(c(5,5,5,5)),
        legend.text=element_text(size=11)) +
  expand_limits(y=0) +
  scale_y_continuous(breaks=seq(0,500,by=100)) +
  ylab("") +
  labs(tag = "(b)")

fig_1b

ggsave('figs/fig1_b.png', width = 5, height = 4.1)


library(gridExtra)

png("figs/fig1.png", width=10, height=4.1, units="in", res=300)
grid.arrange(fig_1a, fig_1b, nrow=1)
dev.off()
  