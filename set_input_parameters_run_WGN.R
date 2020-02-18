
# Set run_name, output directory & input parameter values
#===================================================================================================

run_name <- "run3"
out_dir <- "C:/Users/a1227855/Documents/toyWGN_outputs"

mu <- c(-2, -4, -3, -2, -1, -1, -0.5, -0.5, -1, -2, -2, -3)
sigma <- c(1, 1.2, 1.5, 1.4, 1, 1, 1.1, 0.8, 0.7, 0.7, 0.9, 1)
alpha <- c(0.8, 0.7, 0.6, 0.55, 0.5, 0.4, 0.45, 0.5, 0.6, 0.7, 0.75, 0.8)
lambda <- c(1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8)
nyears <- 122
replicates <- 20

# Generate WGN time series
#====================================================================================================

wgn_data_rep <- gen_WGN_ts(mu, sigma, alpha, lambda, nyears = 122, replicates = 20)

# Save
out_filename <- paste(c(out_dir, "/WGN_data/", run_name, "_wgn_data.RData"), collapse = "")
save(mu, sigma, alpha, lambda, wgn_data_rep, file = out_filename)


# Calculate statistics
#====================================================================================================

wgn_data_rep_stats <- calc_rep_stats(wgn_data_rep)

# Save
out_filename <- paste(c(out_dir, "/WGN_data/", run_name, "_wgn_data_stats.RData"), collapse = "")
save(mu, sigma, alpha, lambda, wgn_data_rep_stats, file = out_filename)

# Create plot
#=====================================================================================================

out_filename <- paste(c(out_dir, "/WGN_plots/", run_name, "_wgn_stats.pdf"), collapse = "")
plot_rep_stats(wgn_data_rep_stats, out_filename)
