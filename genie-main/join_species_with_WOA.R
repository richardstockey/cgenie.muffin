#!/usr/bin/env Rscript

# Load packages
suppressPackageStartupMessages({
  library(dplyr)
  library(sf)
})

# -------------------------------
# 1. Parse SLURM array index
# -------------------------------
task_id <- as.integer(Sys.getenv("SLURM_ARRAY_TASK_ID"))
if (is.na(task_id)) {
  stop("SLURM_ARRAY_TASK_ID not found.")
}

# Define decades and months
decades <- c("1955-1964", "1965-1974", "1975-1984",
             "1985-1994", "1995-2004", "2005-2014", "2015-2022")

months <- 1:12

# Map task ID → (decade, month)
# 7 decades * 12 months = 84 combinations
combos <- expand.grid(decade = decades, month = months)
current <- combos[task_id, ]

decade_now <- current$decade
month_now  <- current$month

cat("Processing decade:", decade_now, " month:", month_now, "\n")

# -------------------------------
# 2. Load datasets
# -------------------------------
species_sf <- readRDS("species_sf.rds")
woa_sf     <- readRDS("woa_sf.rds")

# -------------------------------
# 3. Subset to current decade & month
# -------------------------------

species_sub <- species_sf %>%
  filter(decade == decade_now,
         month_recorded == month_now)

if (nrow(species_sub) == 0) {
  cat("No species records for this combo. Skipping.\n")
  quit(save = "no")
}

woa_sub <- woa_sf %>%
  filter(decade == decade_now,
         month == month_now)

if (nrow(woa_sub) == 0) {
  stop("WOA subset is empty — unexpected.")
}

cat("Species records:", nrow(species_sub), "\n")
cat("WOA grid cells:", nrow(woa_sub), "\n")

# -------------------------------
# 4. Nearest-neighbour spatial join
# -------------------------------

joined <- st_join(species_sub, woa_sub, join = st_nearest_feature)

# -------------------------------
# 5. Save output
# -------------------------------

outfile <- sprintf("joined_output/joined_%s_month_%02d.rds",
                   decade_now, month_now)

dir.create("joined_output", showWarnings = FALSE)

saveRDS(joined, outfile)

cat("Saved:", outfile, "\n")
