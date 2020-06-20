#' Clone Or Download All GitHub Repositories For A User
#'
#' Clone all of a GitHub user's repositories to your computer, or download them
#' all as zip files and then optionally unzip them. Make sure you've got a
#' GitHub account and have generated a GitHub PAT token and stored it your
#' .Renviron. See package README for details.
#'
#' @param gh_user Character string. A GitHub user name.
#' @param dest_dir Character string. A local file path where the zipped repositories
#'     will be downloaded to.
#' @param copy_type Character string. Specify whether to \code{"download"}
#'     or \code{"clone"} the repos to your local machine.
#'
#' @return GitHub repositories either (a) downloaded or (b) cloned in the
#'     specified local directory.
#' @export
#'
#' @examples
#' \dontrun{
#' ghd_get(
#'   gh_user = "matt-dray",
#'   dest_dir = "~/Documents/repos",
#'   copy_type = "clone"
#' )
#' }
ghd_copy <- function(gh_user, dest_dir, copy_type = c("download", "clone")) {

  if (is.character(gh_user) == FALSE) {
    stop("Argument gh_user must be a character string that's a GitHub user.\n")
  }

  if (is.character(dest_dir) == FALSE) {
    stop("Argument dest_dir must be a character string that represents a file path.\n")
  }

  # Accepted strings as answers from users
  affirm <- c("y", "Y", "yes", "Yes", "YES")
  deny <- c("n", "N", "no", "No", "NO")

  # Check if directory exists; ask user if they want to create it
  if (!isTRUE(dir.exists(dest_dir))) {

    # Ask user to create directory if it doesn't exist
    q_create_dir <- readline(
      prompt = paste0("Create new directory at path ", dest_dir, "? y/n: ")
    )

    # Create the directory if 'yes'
    if (q_create_dir %in% affirm) {
      dir.create(path = dest_dir)
    } else if (q_create_dir %in% deny) {
      stop("Aborted by user choice. Please choose a different directory.\n")
    } else {
      stop("Aborted. Input not understood.\n")
    }

  }

  gh_response <- ghd_get_repos(gh_user)

  names_vec <- ghd_extract_names(gh_response)

  if (copy_type == "download") {

    repos_df <- ghd_enframe_urls(names_vec, gh_user)

    ghd_download_zips(repos_df, dest_dir)

    q_unzip <- readline("Unzip all folders? y/n: ")
    if (q_unzip %in% affirm) {
      ghd_unzip(dest_dir)
    } else if (q_unzip %in% deny) {
      cat("dest_directories will not be unzipped.\n")
    } else {
      cat(
        "Input not understood. dest_directories will not be unzipped.\n",
        "See ?ghdump:::ghd_unzip() to unzip the dest_directories yourself.\n"
      )
    }

    cat("Finished downloading\n")

  } else if (copy_type == "clone") {

    ghd_clone_multi(gh_user, names_vec, dest_dir)

    cat("Finished cloning\n")

  }

}
