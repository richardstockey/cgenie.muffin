library(PaleoClimR)

# library(devtools)
# remove.packages('PaleoClimR')
# install_github('richardstockey/PaleoClimR')
library(PaleoClimR)
library(ggplot2)
library(deeptime)
library(dplyr)
library(reshape2)
library(patchwork)
library(egg)
file.name <- "HADCM3-cGENIE-comparison-z32"
format <- "png"
# this is messy <-  combining two ensembles just to see how things look
#map_directory <- "~/phanerozoic.cGENIExl/HADCM3 maps/"
# map_directory <- "/Users/rgs1e22/Documents/Southampton/SOES Research/Phanerozoic.genie/circulation-maps/"
output_directory <- "/mainfs/scratch/rgs1e22/cgenie_output/"
# output_directory <- "/Users/rgs1e22/Temporary-big-files/z32/"
summary_directory <- "~/"

start_age <- 541 
end_age <- 0

age.list <- c(
  '541',
  '535',
  '530',
  '525',
  '520',
  '515',
  '510',
  '505',
  '498',
  '495',
  '491',
  '485',
  '481',
  '475',
  '470',
  '465',
  '460',
  '455',
  '449',
  '444',
  '441',
  '436',
  '430',
  '425',
  '421',
  '415',
  '410',
  '405',
  '400',
  '395',
  '390',
  '385',
  '380',
  '375',
  '370',
  '365',
  '358',
  '354',
  '349',
  '344',
  '338',
  '333',
  '330',
  '327',
  '319',
  '314',
  '311',
  '305',
  '301',
  '297',
  '292',
  '286',
  '280',
  '275',
  '268',
  '265',
  '262',
  '256',
  '252',
  '244',
  '239',
  '233',
  '232',
  '227',
  '222',
  '217',
  '213',
  '204',
  '201',
  '196',
  '190',
  '186',
  '178',
  '172',
  '168',
  '164',
  '160',
  '154',
  '148',
  '145',
  '142',
  '136',
  '131',
  '127',
  '121',
  '115',
  '111',
  '107',
  '102',
  '097',
  '091',
  '086',
  '080',
  '075',
  '069',
  '066',
  '060',
  '055',
  '052',
  '044',
  '039',
  '035',
  '031',
  '025',
  '019',
  '014',
  '010',
  '004',
  '000'
)

streamfunction_summary <- data.frame(
  lon.mid = numeric(),
  lon.min = numeric(),
  lon.max = numeric(),
  lat.mid = numeric(),
  lat.min = numeric(),
  lat.max = numeric(),
  var = numeric(),
  var_norm = numeric(),
  matched_cgenie_var = numeric(),
  age = numeric()
)

O2.vec <- as.numeric()
temp.vec <- as.numeric()
age.vec <- as.numeric()

age.list <- rev(age.list)

# make vent.age.summary.all data frame (empty)
vent.age.summary.all <- data.frame(
  age = numeric(),
  clim = character(),
  res.age = numeric()
)

clim_steps <- c("_0.25x", "_0.5x", "_0.75x", "", "_2x", "_4x")

# for (no in 1:length(age.list)) {
for (no in 1:4) {
  print(paste0("Processing age: ", age.list[no], " million years ago."))
  for(clim.step in clim_steps){
  try({
    exp <- NA
    exp <- paste0(output_directory, "muffin.CB.L23z_", age.list[no], "_z32", clim.step, ".BASES-1.config")
    
    test.file <- paste0(exp, "/biogem/biogem_series_misc_opsi.res")
    if (file.exists(test.file) == FALSE) {
      exp <- paste0(output_directory, "muffin.CB.L23z_", age.list[no], "_z32.BASES-1.config")
    }
    
    age <- as.numeric(age.list[no])
    age.text <- age.list[no]
    
    stages <- deeptime::stages
    for (row in 1:nrow(stages)) {
      stages$between[row] <- between(age, stages$min_age[row], stages$max_age[row])
    }
    if (age == 541) {
      age_colour <- "#99B575"
      stage_name <- "Fortunian"
    } else {
      age_colour <- stages$color[stages$between == TRUE]
      stage_name <- stages$name[stages$between == TRUE]
    }
    
    res.ages <- NA
    res.age.stable.benthic <- NA
    res.ages <- cGENIE.res.import(experiment = exp, var = "misc_col_age")
    
    res.age.stable <- filter(res.ages, `% time (yr)` > 1500)
    res.age.stable.benthic <- mean(res.age.stable$`benthic [> 2000 m] ventilation age (yr)`, na.rm = TRUE)
    print(res.age.stable.benthic)
    # add vent.age stats and age to a summary frame
    vent.age.summary <- data.frame(
      age = age,
      clim = clim.step, 
      res.age = res.age.stable.benthic
    )
    
    # bind summary to master summary
    vent.age.summary.all <- rbind(vent.age.summary.all, vent.age.summary)
    
    print(paste0("Completed processing for age: ", age.text, " (Stage: ", stage_name, ")."))
    
  })
  }
}
vent.age.plot <- ggplot(vent.age.summary.all, aes(x = age)) +
  geom_line(aes(y = res.age, color = clim), size = 1.2) +
  geom_point(aes(y = res.age, color = clim), size = 2.5) +
  scale_x_reverse(limits = c(550, -10), expand = c(0, 0)) +
  labs(
    x = "Age (million years ago)",
    y = "Mean Ventilation Age Below 2000m (years)",
    title = "Mean Ventilation Age Through Time",
    subtitle = "Purple - Stockey (in prep, res); Blue - Stockey (in prep, volume averaged); Pink - Pohl et al. (2022, Nature)"
  ) +
  theme_minimal(base_size = 14) +
  theme(
    panel.grid.major = element_blank(),
    panel.grid.minor = element_blank(),
    panel.border = element_rect(colour = "black", fill = NA, size = 1),
    axis.line = element_line(colour = "black", size = 0.8),
    axis.ticks = element_line(colour = "black", size = 0.8),
    plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
    plot.subtitle = element_text(size = 12, hjust = 0.5)
  )

# # save plot
# ggsave(file = paste0(summary_directory, "/cGENIE_ventilation_age_through_time-Pohl_comparison.", format), vent.age.plot.comp, height = 13, width = 18, units = "cm")
# 
# 



# 
# 
# # make ggplot of vent.age.summary.all with time going from 540 to 0 on x-axis
# # and vent age on y-axis. Points and line for mean, envelope for 25th and 75th percentile. Shaded area for 5th and 95th percentile.
# 
# vent.age.plot <- ggplot(vent.age.summary.all, aes(x = age)) +
#   geom_ribbon(aes(ymin = p05, ymax = p95), fill = "#B3CDE3", alpha = 0.6) +
#   geom_ribbon(aes(ymin = p25, ymax = p75), fill = "#6497B1", alpha = 0.6) +
#   geom_line(aes(y = mean), color = "#005B96", size = 1.2) +
#   geom_point(aes(y = mean), color = "#03396C", size = 2.5) +
#   geom_line(aes(y = res.age), color = "#6C5B7B", size = 1.2) +
#   geom_point(aes(y = res.age), color = "#6C5B7B", size = 2.5) +
#   scale_x_reverse(limits = c(550, -10), expand = c(0, 0)) +
#   labs(
#     x = "Age (million years ago)",
#     y = "Mean Ventilation Age Below 2000m (years)",
#     title = "Mean Ventilation Age Through Time",
#     subtitle = "Purple - Stockey (in prep, res); Blue - Stockey (in prep, volume averaged); Pink - Pohl et al. (2022, Nature)"
#   ) +
#   theme_minimal(base_size = 14) +
#   theme(
#     panel.grid.major = element_blank(),
#     panel.grid.minor = element_blank(),
#     panel.border = element_rect(colour = "black", fill = NA, size = 1),
#     axis.line = element_line(colour = "black", size = 0.8),
#     axis.ticks = element_line(colour = "black", size = 0.8),
#     plot.title = element_text(face = "bold", size = 16, hjust = 0.5),
#     plot.subtitle = element_text(size = 12, hjust = 0.5)
#   )
# 
# 
# vent.age.plot
