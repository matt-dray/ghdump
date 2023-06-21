# Purpose: clone repos

#' Clone One Repo From A GitHub User
#'
#' Clone a repo for a specified user to a specified local repository.
#'
#' If you're using \code{protocol = "ssh"}, you need to make sure you have
#' \href{https://happygitwithr.com/ssh-keys.html}{set up your SSH keys}.
#'
#' @param gh_user Character string. A GitHub user name.
#' @param repo Character string. A GitHub repo name for the named \code{gh_user}.
#' @param protocol Character string. Either \code{"https"} or \code{"ssh"}.
#' @param dest_dir Character string. A local file path where the zipped
#'     repositories will be downloaded to. Must be a full path.
#'
#' @details If you're using \code{protocol = "ssh"}, you need to make sure
#'     you've \href{https://happygitwithr.com/ssh-keys.html}{set up your SSH keys}.
#'
#' @return The named user's named repo cloned to the specified location.
ghd_clone_one <- function(gh_user, repo, protocol, dest_dir) {

  if (!protocol %in% c("https", "ssh")) {

    cli::cli_abort(
      "You must provide either 'https' or 'ssh' to the protocol argument."
    )
  }

  # Pass a system call to clone the repo to the destination
  # Different

  if (protocol == "https") {

    system(
      paste0(
        "git clone https://github.com/", gh_user, "/", repo, ".git ",
        dest_dir, "/", repo
      )
    )

  } else if (protocol == "ssh") {

    system(
      paste0(
        "git clone git@github.com:", gh_user, "/", repo, ".git ",
        dest_dir, "/", repo
      )
    )

  }

}

#' Clone Multiple Repos From A GitHub User
#'
#' Iterate over multiple repos for a given GitHub user, cloning them to a
#' specified local repository.
#'
#' @param gh_user Character string. A GitHub user name.
#' @param names_vec Character vector. Repo names for the given \code{gh_user}.
#' @param protocol Character string. Either \code{"https"} or \code{"ssh"}.
#' @param dest_dir Character string. A local file path where the zipped repositories
#'     will be downloaded to. Must be a full path.
#'
#' @details If you're using \code{protocol = "ssh"}, you need to make sure
#'     you've \href{https://happygitwithr.com/ssh-keys.html}{set up your SSH keys}.
#'
#' @return The named user's named repos cloned to the specified location.
ghd_clone_multi <- function(gh_user, names_vec, protocol, dest_dir) {

  # Ask if all the repos should be downloaded
  q_clone_all <- readline(
    prompt = paste0("Definitely clone all ", length(names_vec), " repos? y/n: ")
  )

  is_yes <- substr(tolower(q_clone_all), 1, 1) == "y"
  is_no <- substr(tolower(q_clone_all), 1, 1) == "n"

  # React to user input
  if (is_yes) {

    cli::cli_alert_info("Cloning repositories to {dest_dir}.")

    # Prepare safe file clone (passes over failures)
    clone_safely <-
      purrr::safely(
        ~ ghd_clone_one(
          gh_user = gh_user,
          repo = .x,
          protocol = protocol,
          dest_dir = dest_dir
        )
      )

    # Clone each repo
    purrr::walk(
      .x = names_vec,
      .f = clone_safely
    )

  } else if (is_no) {

    cli::cli_abort("Aborted by user choice.")

    stop("Aborted by user choice.\n")

  } else {

    cli::cli_abort("Aborted. Input not understand.")

  }

}
