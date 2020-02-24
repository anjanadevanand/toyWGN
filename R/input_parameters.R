toyWGN_param.env <- new.env(parent = emptyenv())

#---- Parameters in the environment -------

toyWGN_param.env$mu <- c(-2, -4, -3, -2, -1, -1, -0.5, -0.5, -1, -2, -2, -3)
toyWGN_param.env$sigma <- c(1, 1.2, 1.5, 1.4, 1, 1, 1.1, 0.8, 0.7, 0.7, 0.9, 1)
toyWGN_param.env$alpha <- c(0.8, 0.7, 0.6, 0.55, 0.5, 0.4, 0.45, 0.5, 0.6, 0.7, 0.75, 0.8)
toyWGN_param.env$lambda <- c(1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8, 1.8)

# NOTE: Need to think about how to include examples for modify_namelist using an input JSON file in the top level directory
#' Modify parameters of the weather generator
#'
#' \code{modify_namelist} modifes the values of the WGN parameters as per user input
#'
#' @param user_file A JSON file; containing name value pairs of the user input parameters
#' @return The function does not return anything. It modifies the parameter values inside the parameter environment in place.
#' @export

modify_namelist <- function(user_file = "user_namelist.json") {
  user_namelist <- jsonlite::fromJSON(txt = user_file)
  for (i_nl in 1:length(user_namelist)) {
    print(names(user_namelist)[i_nl])
    assign(names(user_namelist)[i_nl], user_namelist[[i_nl]], toyWGN_param.env)
  }
  invisible()
}

#' Write parameters of the weather generator to file
#'
#' \code{output_namelist} writes the current value of the WGN parameters to a JSON file
#'
#' @param out_file the name of the JSON file to be output
#' @return The current value of all the WGN parameters in the JSON file
#' @export

write_namelist <- function(out_file = "output_namelist") {
  param_names <- ls(envir = toyWGN_param.env)

  list_output_namelist <- NULL
  for (i_param in 1:length(param_names)) {
    list_output_namelist[[i_param]] <- get(param_names[i_param], envir = toyWGN_param.env)
    }
  names(list_output_namelist) <- param_names

  json_output_namelist <- jsonlite::toJSON(list_output_namelist, pretty = TRUE)
  write(json_output_namelist, file = paste0(out_file, ".json"))
  invisible()
}


