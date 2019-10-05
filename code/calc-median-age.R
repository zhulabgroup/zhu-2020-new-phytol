library(raster)

# get fractions of 4 PFT
frac_NEEV_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 1)
frac_NEDC_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 2)
frac_BRDC_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 3)
frac_BREV_brick <- brick("data/GFAD/GFAD_V1-1/GFAD_V1-1.nc", level = 4)

# add fractions of all PFTs
frac_sum <- frac_NEEV_brick + frac_NEDC_brick + frac_BRDC_brick + frac_BREV_brick
plot(frac_sum)

# find medians
frac_sum_df <- as.data.frame(frac_sum, xy = T)

head(frac_sum_df)
dim(frac_sum_df)[1]
for (i in 1:dim(frac_sum_df)[1]) {
  median <- 0
  frac <- 0
  frac_total <- sum(frac_sum_df[i, 3:17])
  if (frac_total > 0) {
    for (j in 1:15) {
      frac <- frac + frac_sum_df[i, j + 2]
      if (frac <= 0.5 * frac_total) median <- median + 1
    }
    median <- median + 1
  }
  frac_sum_df$median[i] <- median
}

# double-check if medians are correct
head(frac_sum_df)
frac_sum_df[107467, ]
frac_sum_df[150000, ]

# output results
write.csv(frac_sum_df, "data/median-age.csv")
