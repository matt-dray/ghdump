# Purpose: fetch GitHub repo information and extract repo names

#' Get GitHub Repo Information for a Named User
#'
#' Uses \code{\link[gh]{gh}} to access the GitHub API and get the details for
#' all of a named user's repos. To use this function you need to have created a
#' GitHub account and to have put a GitHub Personal Access Token (PAT) in your
#' .Renviron. See \href{https://happygitwithr.com/github-pat.html}{Happy Git and GitHub for the UseR}
#' for omre information.
#'
#' @param gh_user Character string. A GitHub username.
#'
#' @return A gh_response object.
ghd_get_repos <- function(gh_user) {

  cat("Fetching GitHub repos for user", gh_user, "\n")

  user_repos <-
    gh::gh(
      endpoint = "/users/:username/repos",
      username = gh_user,
      .limit = Inf  # get all repos
    )

  return(user_repos)

}

#' Extract Names of GitHub Repos
#'
#' Extract all the 'name' elements from a gh_response object. These are the
#' names of all the GitHub repos.
#'
#' @param repo_object A gh_response object, as returned by \code{\link{ghd_get_repos}}.
#'
#' @return A character vector of GitHub repo names.
ghd_extract_names <- function(repo_object) {

  repo_names <-
    purrr::map(
      .x = repo_object,
      .f = purrr::pluck("name")
    )

  repo_names_vec <- unlist(repo_names)

  cat(length(repo_names), "repos found\n")

  return(repo_names_vec)

}
