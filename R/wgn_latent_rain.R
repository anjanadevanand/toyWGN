#' Generate timeseries of a climate variable using a latent-variable model.
#'
#' \code{wgn_latent_model} returns timeseries of a climate variable using the values present in its arguments.
#'
#' The latent-variable model used by this function is of the form
#' \deqn{X_t = \alpha(X_{t-1} - \mu) + \epsilon_t}
#' \deqn{\epsilon_t ~ N(0, \sigma^2)}
#' \deqn{R = X^\lambda if X > 0}
#'
#' @param mu A number; mean of the latent variable \emph{X}.
#' @param sigma A number; standard deviaion of the latent variable \emph{X}.
#' @param alpha A number; lag-1 autocorrelation coefficient of the latent variable \emph{X}.
#' @param lambda A number; exponent of the latent variable \emph{X}.
#' @param tot_days Number of values to return.
#' @return The climate timeseries of length \code{tot_days}.
#' @examples
#' wgn_latent_model(-2, 1, 0.8, 1.2, 100)
#' @export

wgn_latent_model <- function(mu, sigma, alpha, lambda, tot_days) {

  X <- rep(0, tot_days)
  R <- rep(0, tot_days)

  X[1] <- rnorm(1, 0, sigma)

  for (i_day in 2:length(X)){
    X[i_day] <- alpha * X[i_day-1] + rnorm(1, mean = 0, sd = sigma)
  }

  X <- X + mu

  X_pos_ind <- which(X > 0)
  R[X_pos_ind] <- X[X_pos_ind]^lambda

  return(R)
}

#' Get indices correponding to the 12 months for a vector of dates.
#'
#' \code{get_mon_indices} returns a 12 element list of vectors containing the indices of dates the corresponding to each month
#' in the input vector argument.
#'
#' @param date_vec vector of dates of class \code{Date} or \code{character}
#' @return list of indices of dates corresponding to each month
#' @keywords internal

get_mon_indices <- function(date_vec) {

  mon_indices <- vector(mode = "list", length = 12)
  for (i_mon in 1:12) {
    mon_indices[[i_mon]] <- which(as.POSIXlt(date_vec)$mon == (i_mon - 1))
  }

  return(mon_indices)
}

#' Generate replicates of timeseries of a climate variable using a monthly latent variable model.
#'
#' \code{gen_WGN_ts} returns replicates of timeseries of a climate variable using the function \code{wgn_latent_model}.
#'
#' @param mu vector of numbers of length 12; mean of the latent variable \emph{X} for each month.
#' @param sigma vector of numbers of length 12; standard deviaion of the latent variable \emph{X} for each month.
#' @param alpha vector of numbers of length 12; lag-1 autocorrelation coefficient of the latent variable \emph{X} for each month.
#' @param lambda vector of numbers of length 12; exponent of the latent variable \emph{X} for each month.
#' @param nyears number of years of data to be generated.
#' @param replicates number of replicates of the timeseries to be generated.
#' @return A list of length \code{replicates} containing the replicates of \code{nyears} of climate variable timeseries.
#' @examples
#' mu <- c(-2, -4, -3, -2, -1, -1, -0.5, -0.5, -1, -2, -2, -3)
#' sigma <- c(1, 1.2, 1.5, 1.4, 1, 1, 1.1, 0.8, 0.7, 0.7, 0.9, 1)
#' alpha <- c(0.8, 0.7, 0.6, 0.55, 0.5, 0.4, 0.45, 0.5, 0.6, 0.7, 0.75, 0.8)
#' lambda <- c(1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2, 1.2)
#' wgn_data_rep <- gen_WGN_ts(mu, sigma, alpha, lambda, nyears = 10, replicates = 5)
#' @export

gen_WGN_ts <- function(mu, sigma, alpha, lambda, nyears = 122, replicates = 20) {

  # Create a date vector for the time dimension of the WGN series & save indices for each month
  #===================================================================================================

  date_vec <- seq(as.Date(paste(c(toString(0), "/01/01"), collapse = "")), as.Date(paste(c(toString(nyears-1), "/12/31"), collapse = "")), by = "day")
  mon_indices <- get_mon_indices(date_vec)


  # WGN - Loop over replicates
  #====================================================================================================

  wgn_data_rep <- vector(mode = "list", length = replicates)

  for (i_rep in 1:replicates) {

    # Create a data vector for WGN output & name the time dimension
    #==================================================================================================

    wgn_data_vec <- rep(NA, length(date_vec))
    names(wgn_data_vec) <- date_vec

    # Run WGN to generate data - separately for each month
    #==================================================================================================

    for (i_mon in 1:12){
      wgn_data_vec[mon_indices[[i_mon]]] <- wgn_latent_model(mu[i_mon], sigma[i_mon], alpha[i_mon], lambda[i_mon], length(mon_indices[[i_mon]]))
    }
    wgn_data_rep[[i_rep]] <- wgn_data_vec
    rm(wgn_data_vec)

  }

  return(wgn_data_rep)
}

