
#' Plot statistics calculated from a climate variable timeseries.
#'
#' \code{plot_rep_stats} creates a plot of the statistics of the timeseries replicates
#' calculated by \code{calc_rep_stats}.
#'
#' The plot contains panels for each statistic, and compares the charateristics of the
#' replicates with an observation data.
#'
#' @param wgn_rep_stats A list of named dataframes containing the statistics to be plotted.
#' Typically calculated using \code{calc_rep_stats}
#' @param out_filename Full path and filename of the output pdf file to be generated
#' @return A pdf file containing plot of the statistics
#' @export

plot_rep_stats <- function(wgn_rep_stats, out_filename) {

  # OBS data
  #====================================================
  #obs_filename <- "data/obs_rain_stats.RData"
  #load(obs_filename)


  pdf(file = out_filename,
       width = 11.69, height = 6)

  par(mfrow=c(2,4))

  matplot(wgn_rep_stats$ann_tot[ ,-1], type = "l", lty = 1, col = "lightblue", main = "Annual Total Rain (unit)", xlab = "Years (sorted)", ylab = "")
  lines(obs_ann_rain_tot, type = "l", col = "red", pch = 21, bg = "red")

  matplot(wgn_rep_stats$ann_max[ ,-1], type = "l", lty = 1, col = "lightblue", main = "Annual Maximum Daily Rain (unit)", xlab = "Years (sorted)", ylab = "")
  lines(obs_ann_rain_max, type = "l", col = "red", pch = 21, bg = "red")

  boxplot(wgn_rep_stats$mon_mean[ ,-1], main = "Mean: Monthly Rainfall (unit)", xlab = "Months", ylab = "", col = "lightblue")
  lines(obs_mon_rain_mean, type = "b", col = "red", pch = 21, bg = "red")

  boxplot(wgn_rep_stats$mon_sd[ ,-1], main = "SD: Monthly Rainfall (unit)", xlab = "Months", ylab = "", col = "lightblue")
  lines(obs_mon_rain_sd, type = "b", col = "red", pch = 21, bg = "red")

  boxplot(wgn_rep_stats$cor_wetdays_daily[ ,-1], main = "Correlation of Wet Day Rain", xlab = "Months", ylab = "", col = "lightblue")
  lines(obs_cor_wetdays_daily, type = "b", col = "red", pch = 21, bg = "red")

  boxplot(wgn_rep_stats$var_wetdays_daily[, -1], main = "Variance of Wet Day Rain", xlab = "Months", ylab = "", col = "lightblue")
  lines(obs_var_wetdays_daily, type = "b", col = "red", pch = 21, bg = "red")

  boxplot(wgn_rep_stats$pdry[ ,-1], main = "Proportion of Dry Days", xlab = "Months", ylab = "", col = "lightblue")
  lines(obs_pdry, type = "b", col = "red", pch = 21, bg = "red")

  dev.off()

}
