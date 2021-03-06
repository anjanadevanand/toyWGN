% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/plot_wgn_data_stats_rep.R
\name{plot_rep_stats}
\alias{plot_rep_stats}
\title{Plot statistics calculated from a climate variable timeseries.}
\usage{
plot_rep_stats(wgn_rep_stats, out_filename)
}
\arguments{
\item{wgn_rep_stats}{A list of named dataframes containing the statistics to be plotted.
Typically calculated using \code{calc_rep_stats}}

\item{out_filename}{Full path and filename of the output pdf file to be generated}
}
\value{
A pdf file containing plot of the statistics
}
\description{
\code{plot_rep_stats} creates a plot of the statistics of the timeseries replicates
calculated by \code{calc_rep_stats}.
}
\details{
The plot contains panels for each statistic, and compares the charateristics of the
replicates with an observation data.
}
