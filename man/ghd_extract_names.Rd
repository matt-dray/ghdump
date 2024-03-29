% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/01-repo-names.R
\name{ghd_extract_names}
\alias{ghd_extract_names}
\title{Extract Names of GitHub Repos}
\usage{
ghd_extract_names(repo_object)
}
\arguments{
\item{repo_object}{A gh_response object, as returned by
\code{\link{ghd_get_repos}}.}
}
\value{
A character vector of GitHub repo names.
}
\description{
Extract all the 'name' elements from a gh_response object. These are the
names of all the GitHub repos.
}
