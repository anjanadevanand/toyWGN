
#' Abort for a NULL or type-mismatched argument
#'
#' \code{abort_bad_argument} stops execution and prints appropriate error message.
#'
#' @param arg argument causing the error
#' @param must string specifying the desired type of \code{arg}
#' @param not current value of the \code{arg}
#' @keywords internal

abort_bad_argument <- function(arg, must, not = NULL) {
  msg <- glue::glue("'{arg}` must {must}")
  if (!is.null(not)) {
    not <- typeof(not)
    msg <- glue::glue("{msg}; not {not}.")
  }

  rlang::abort("error_bad_argument",
               message = msg,
               arg = arg,
               must = must,
               not = not
  )
}

#' Abort for a infeasible argument
#'
#' \code{abort_infeasible_argument} stops execution and prints appropriate error message.
#'
#' @param arg argument causing the error
#' @param must string specifying the infeasibility of \code{arg}
#' @keywords internal

abort_infeasible_argument <- function(arg, must, not) {
  msg <- glue::glue("'{arg}` must {must}; not {not}")
  rlang::abort("error_infeasible_argument",
               message = msg,
               arg = arg,
               must = must,
               not = not
  )
}


#' Abort for a incorrect argument length/dimension
#'
#' \code{abort_argument_dim} stops execution and prints appropriate error message.
#'
#' @param arg argument causing the error
#' @param must string specifying the desired dimension of \code{arg}
#' @param not current value of the \code{arg}
#' @keywords internal

abort_argument_dim <- function(arg, must, not = NULL) {
  msg <- glue::glue("'{arg}` must {must}")

  if (!is.vector(not)) {
    not <- dim(not)
    msg <- glue::glue("{msg}; not of dimension {not}.")
  } else {
    not <- length(not)
    msg <- glue::glue("{msg}; not of length {not}.")
  }
  rlang::abort("error_argument_dim",
               message = msg,
               arg = arg,
               must = must,
               not = not
  )
}
