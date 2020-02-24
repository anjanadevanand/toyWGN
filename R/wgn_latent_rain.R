#' @importFrom stats rnorm
NULL

#******** CONVERT 'wgn_latent_model' FUNCTION INTO AN INTERNAL FUNCTION LATER ***********************

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

  # Conditions on arguments,  1) Numeric
  #==========================================================================================
  if (!is.numeric(mu)) {
    abort_bad_argument("mu", must = "be numeric", not = mu)
  }

  if (!is.numeric(sigma)) {
    abort_bad_argument("sigma", must = "be numeric", not = sigma)
  }

  if (!is.numeric(alpha)) {
    abort_bad_argument("alpha", must = "be numeric", not = alpha)
  }

  if (!is.numeric(lambda)) {
    abort_bad_argument("lambda", must = "be numeric", not = lambda)
  }

  if (!is.numeric(tot_days)) {
    abort_bad_argument("tot_days", must = "be numeric", not = tot_days)
  }

  # Conditions on arguments, 2 Length/dimension
  #==========================================================================================
  if (length(mu) != 1) {
    abort_argument_dim("mu", must = "be a one number", not = mu)
  }

  if (length(sigma) != 1) {
    abort_argument_dim("sigma", must = "be a one number", not = sigma)
  }

  if (length(alpha) != 1) {
    abort_argument_dim("alpha", must = "be a one number", not = alpha)
  }

  if (length(lambda) != 1) {
    abort_argument_dim("lambda", must = "be a one number", not = lambda)
  }

  if (length(tot_days) != 1) {
    abort_argument_dim("tot_days", must = "be a one number", not = tot_days)
  }


  # Conditions on arguments, 3) Infeasible values
  #==========================================================================================
  if (sigma <= 0) {
    abort_infeasible_argument("sigma", must = "be greater than zero", not = sigma)
  }

  if (alpha == 0 | alpha <= -1 | alpha >= 1) {
    abort_infeasible_argument("alpha", must = "be non-zero, and fall between (-1, 1)", not = alpha)
  }

  if (lambda == 0) {
    abort_infeasible_argument("lambda", must = "be non-zero", not = lambda)
  }

  if (tot_days <= 0 | tot_days %% 1 != 0) {
    abort_infeasible_argument("tot_days", must = "be an integer greater than zero", not = tot_days)
  }


  # Code
  #==========================================================================================
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
#' @noRd

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
#' The parameters of the weather generator are stored in toyWGN_param.env. The user may use the function \code{modify_namelist}
#' to modfiy the default parameters of the weather generator. This WGN model uses the parameters:
#' \itemize{
#'   \item mu vector of numbers of length 12; mean of the latent variable \emph{X} for each month.
#'   \item sigma vector of numbers of length 12; standard deviaion of the latent variable \emph{X} for each month.
#'   \item alpha vector of numbers of length 12; lag-1 autocorrelation coefficient of the latent variable \emph{X} for each month.
#'   \item lambda vector of numbers of length 12; exponent of the latent variable \emph{X} for each month.
#'   }
#' @param nyears number of years of data to be generated.
#' @param replicates number of replicates of the timeseries to be generated.
#' @return A list of length \code{replicates} containing the replicates of \code{nyears} of climate variable timeseries.
#' @seealso \code{write_namelist}, \code{modify_namelist}
#' @examples
#' wgn_data_rep <- gen_WGN_ts(nyears = 10, replicates = 5)
#' @export

gen_WGN_ts <- function(nyears = 122, replicates = 20) {

  # Get parameters from parameter environment
  #==========================================================================================
  mu <- toyWGN_param.env$mu
  sigma <- toyWGN_param.env$sigma
  alpha <- toyWGN_param.env$alpha
  lambda <- toyWGN_param.env$lambda


  # Conditions on arguments,  1) Numeric
  #==========================================================================================
  if (!is.numeric(mu)) {
    abort_bad_argument("mu", must = "be numeric", not = mu)
  }

  if (!is.numeric(sigma)) {
    abort_bad_argument("sigma", must = "be numeric", not = sigma)
  }

  if (!is.numeric(alpha)) {
    abort_bad_argument("alpha", must = "be numeric", not = alpha)
  }

  if (!is.numeric(lambda)) {
    abort_bad_argument("lambda", must = "be numeric", not = lambda)
  }

  if (!is.numeric(nyears)) {
    abort_bad_argument("nyears", must = "be numeric", not = nyears)
  }

  if (!is.numeric(replicates)) {
    abort_bad_argument("replicates", must = "be numeric", not = replicates)
  }

  # Conditions on arguments, 2 Length/dimension
  #==========================================================================================
  if (length(mu) != 12) {
    abort_argument_dim("mu", must = "be of length 12", not = mu)
  }

  if (length(sigma) != 12) {
    abort_argument_dim("sigma", must = "be of length 12", not = sigma)
  }

  if (length(alpha) != 12) {
    abort_argument_dim("alpha", must = "be of length 12", not = alpha)
  }

  if (length(lambda) != 12) {
    abort_argument_dim("lambda", must = "be of length 12", not = lambda)
  }

  if (length(nyears) != 1) {
    abort_argument_dim("nyears", must = "be one number", not = nyears)
  }

  if (length(replicates) != 1) {
    abort_argument_dim("replicates", must = "be one number", not = replicates)
  }


  # Conditions on arguments, 3) Infeasible values
  #==========================================================================================
  if (any(sigma <= 0)) {
    abort_infeasible_argument("sigma", must = "be greater than zero", not = sigma[sigma <= 0])
  }

  if (any(alpha == 0) | any(alpha <= -1) | any(alpha >= 1)) {
    abort_infeasible_argument("alpha", must = "be non-zero, and fall between (-1, 1)", not = alpha[alpha == 0 | alpha <= -1 | alpha >= 1])
  }

  if (any(lambda == 0)) {
    abort_infeasible_argument("lambda", must = "be non-zero", not = lambda[lambda == 0])
  }

  if (nyears <= 0 | nyears %% 1 != 0) {
    abort_infeasible_argument("nyears", must = "be an integer greater than zero", not = nyears)
  }

  if (replicates <= 0 | replicates %% 1 != 0) {
    abort_infeasible_argument("replicates", must = "be an integer greater than zero", not = replicates)
  }

  # Code

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

