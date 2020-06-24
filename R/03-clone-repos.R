# Purpose: clone repos

#' Clone One Repo From A GitHub User
#'
#' Clone a repo for a specified user to a specified local repository.
#'
#' @param gh_user Character string. A GitHub user name.
#' @param repo Character string. A GitHub repo name for the named \code{gh_user}.
#' @param dest_dir Character string. A local file path where the zipped
#'     repositories will be downloaded to. Must be a full path.
#'
#' @return The named user's named repo cloned to the specified location.
ghd_clone_one <- function(gh_user, repo, dest_dir) {

  system(
    paste0(
      "git clone https://github.com/", gh_user, "/", repo, ".git ",
      dest_dir, "/", repo
    )
  )

}

#' Clone Multiple Repos From A GitHub User
#'
#' Iterate over multiple repos for a given GitHub user, cloning them to a
#' specified local repository.
#'
#' @param gh_user Character string. A GitHub user name.
#' @param names_vec Character vector. Repo names for the given \code{gh_user}.
#' @param dest_dir Character string. A local file path where the zipped repositories
#'     will be downloaded to. Must be a full path.
#'
#' @return The named user's named repos cloned to the specified location.
ghd_clone_multi <- function(gh_user, names_vec, dest_dir) {

  # Ask if all the repos should be downloaded
  q_clone_all <- readline(
    prompt = paste0("Definitely clone all ", length(names_vec), " repos? y/n: ")
  )

  # React to user input
  if (substr(tolower(q_clone_all), 1, 1) == "y") {

    cat("Cloning repositories to", dest_dir, "\n")

    # Prepare safe file clone (passes over failures)
    clone_safely <-
      purrr::safely(
        ~ ghd_clone_one(
          gh_user = gh_user,
          repo = .x,
          dest_dir = dest_dir
        )
      )

    # Clone each repo
    purrr::walk(
      .x = names_vec,
      .f = clone_safely
    )

  } else if (substr(tolower(q_clone_all), 1, 1) == "n") {

    stop("Aborted by user choice.\n")

  } else {

    stop("Aborted. Input not understood.\n")

  }

}
