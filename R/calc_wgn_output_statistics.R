# Code to calculate statistics from saved WGN simulated data

# Calculate Statistics
#======================================================================================


#' Calculate statistics from a climate variable timeseries.
#'
#' \code{calc_ts_stats} returns a list of statistics calculated from an input timeseries.
#'
#' The statistics calculated are:
#' \itemize{
#'   \item annual maximum values (name: \emph{ann_max})
#'   \item annual total values (name: \emph{ann_tot})
#'   \item monthly mean climatology (name: \emph{mon_mean})
#'   \item monthly standard deviation(name: \emph{mon_sd})
#'   \item correlation of subsequent non-zero days by month (name: \emph{cor_wetdays_daily}),
#'   \item variance of non-zero days by month (name: \emph{var_wetdays_daily}),
#'   \item proportion of dry (zero rainfall) days within a month (name: \emph{pdry}).
#' }
#'
#' @param wgn_data_vec A named vector of numbers with names as character dates of the form
#' \code{\%Y-\%m-\%d}; the input daily timeseries.
#' @return A named list of vectors containing the calculated statistics.
#' @export
calc_ts_stats <- function(wgn_data_vec) {

  ann_max <- sort(tapply(wgn_data_vec, as.POSIXlt(names(wgn_data_vec))$year, max))
  ann_tot <- sort(tapply(wgn_data_vec, as.POSIXlt(names(wgn_data_vec))$year, sum))

  mon_indices <- get_mon_indices(names(wgn_data_vec))

  mon_mean <- rep(NA, 12)
  mon_sd <- rep(NA, 12)

  for (i_mon in 1:12) {

    mon_data <- tapply(wgn_data_vec[mon_indices[[i_mon]]], as.POSIXlt(names(wgn_data_vec[mon_indices[[i_mon]]]))$year, sum)
    mon_mean[i_mon] <- mean(mon_data)
    mon_sd[i_mon] <- sd(mon_data)
    rm(mon_data)

  }

  cor_wetdays_daily <- rep(NA, 12)
  var_wetdays_daily <- rep(NA, 12)
  pdry <- rep(NA, 12)

  wgn_data_vec_wetdays <- wgn_data_vec
  wgn_data_vec_wetdays[wgn_data_vec_wetdays == 0] <- NA

  for (i_mon in 1:12) {

    tot_days <- length(mon_indices[[i_mon]])

    # subset data by month (may be possible to avoid copying - rethink cor calculation)
    wgn_data_mon <- wgn_data_vec_wetdays[mon_indices[[i_mon]]]

    # correlation of consecutive wet days in the month
    cor_wetdays_daily[i_mon] <- cor(wgn_data_mon[-tot_days], wgn_data_mon[-1], use = "na.or.complete")

    # variance of wet days in the month
    var_wetdays_daily[i_mon] <- var(wgn_data_mon, use = "na.or.complete")

    # proportion of dry days
    pdry[i_mon] <- sum(is.na(wgn_data_mon)) / tot_days

    rm(wgn_data_mon)

  }
  rm(wgn_data_vec_wetdays)

  return(list(ann_max = ann_max,
              ann_tot = ann_tot,
              mon_mean = mon_mean,
              mon_sd = mon_sd,
              cor_wetdays_daily = cor_wetdays_daily,
              var_wetdays_daily = var_wetdays_daily,
              pdry = pdry))
}


#' Calculate statistics from all the replicates of a generated climate variable timeseries.
#'
#' \code{calc_rep_stats} returns a list of statistics calculated from an input list of timeseries
#' replicates.
#'
#' Uses the function \code{calc_ts_stats} to calculate the statistics for each replicate. The statistics
#' from all the replicates are saved in a dataframe corresponding to each statistic.
#'
#' Similar to \code{calc_ts_stats}, the statistics calculated are:
#' \itemize{
#'   \item annual maximum values (name: \emph{ann_max})
#'   \item annual total values (name: \emph{ann_tot})
#'   \item monthly mean climatology (name: \emph{mon_mean})
#'   \item monthly standard deviation(name: \emph{mon_sd})
#'   \item correlation of subsequent non-zero days by month (name: \emph{cor_wetdays_daily}),
#'   \item variance of non-zero days by month (name: \emph{var_wetdays_daily}),
#'   \item proportion of dry (zero rainfall) days within a month (name: \emph{pdry}).
#' }
#'
#' @param wgn_data_rep A list of vectors containing the replicates of input timeseries.
#' Each element of the list should be a named vector of numbers with names as character dates of the form
#' \code{\%Y-\%m-\%d}.
#' @return A named list of dataframes containing the calculated statistics.
#' @export
calc_rep_stats <- function(wgn_data_rep, nyears = NULL) {

  # WGN statistics calculation - Loop over replicates
  #===================================================================================================
  # Annual rainfall total, Annual rainfall maximum - sorted
  # Monthly rainfall total - mean and standard deviation across years
  # Correlation & variance of wet day rainfall by month (using all nyears of data)
  # Proportion of dry days by month (using all nyears of data)

  replicates <- length(wgn_data_rep)
  if (is.null(nyears)) {nyears <- length(unique(as.POSIXlt(names(wgn_data_rep[[1]]))$year))}

  ann_tot_rep <- matrix(NA, nrow = nyears, ncol = replicates)
  ann_max_rep <- matrix(NA, nrow = nyears, ncol = replicates)

  mon_mean_rep <- matrix(NA, nrow = replicates, ncol = 12)
  mon_sd_rep <- matrix(NA, nrow = replicates, ncol = 12)

  cor_wetdays_daily_rep <- matrix(NA, nrow = replicates, ncol = 12)
  var_wetdays_daily_rep <- matrix(NA, nrow = replicates, ncol = 12)
  pdry_rep <- matrix(NA, nrow = replicates, ncol = 12)

  for (i_rep in 1:replicates) {

    wgn_data_vec <- wgn_data_rep[[i_rep]]
    wgn_data_stats <- calc_ts_stats(wgn_data_vec)

    # Save the statistics for each replicate
    #=================================================================================================
    ann_tot_rep[ ,i_rep] <- wgn_data_stats$ann_tot
    ann_max_rep[ ,i_rep] <- wgn_data_stats$ann_max

    mon_mean_rep[i_rep, ] <- wgn_data_stats$mon_mean
    mon_sd_rep[i_rep, ] <- wgn_data_stats$mon_sd

    cor_wetdays_daily_rep[i_rep, ] <- wgn_data_stats$cor_wetdays_daily
    var_wetdays_daily_rep[i_rep, ] <- wgn_data_stats$var_wetdays_daily
    pdry_rep[i_rep, ] <- wgn_data_stats$pdry

    rm(wgn_data_vec, wgn_data_stats)

  }

  # Name dimensions of statistics
  #===================================================================================================

  # Dimension names -------------------------------
  year_names <- paste(1:nyears)
  rep_names <- paste(1:replicates)
  mon_names <- c("Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec")

  # Assigning dimension names ---------------------
  df_ann_tot <- data.frame(year_names, ann_tot_rep)
  colnames(df_ann_tot) <- c("Years", rep_names)

  df_ann_max <- data.frame(year_names, ann_max_rep)
  colnames(df_ann_max) <- c("Years", rep_names)

  df_mon_mean <- data.frame(rep_names, mon_mean_rep)
  colnames(df_mon_mean) <- c("Replicates", mon_names)

  df_mon_sd <- data.frame(rep_names, mon_sd_rep)
  colnames(df_mon_sd) <- c("Replicates", mon_names)

  df_cor_wetdays_daily <- data.frame(rep_names, cor_wetdays_daily_rep)
  colnames(df_cor_wetdays_daily) <- c("Replicates", mon_names)

  df_var_wetdays_daily <- data.frame(rep_names, var_wetdays_daily_rep)
  colnames(df_var_wetdays_daily) <- c("Replicates", mon_names)

  df_pdry <- data.frame(rep_names, pdry_rep)
  colnames(df_pdry) <- c("Replicates", mon_names)

  rm(ann_tot_rep, ann_max_rep, mon_mean_rep, mon_sd_rep, cor_wetdays_daily_rep, var_wetdays_daily_rep, pdry_rep)

  return(list(ann_max = df_ann_max,
              ann_tot = df_ann_tot,
              mon_mean = df_mon_mean,
              mon_sd = df_mon_sd,
              cor_wetdays_daily = df_cor_wetdays_daily,
              var_wetdays_daily = df_var_wetdays_daily,
              pdry = df_pdry))

}







