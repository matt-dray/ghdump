#' Clone Or Download All GitHub Repositories For A User
#'
#' Clone all of a GitHub user's repositories to your computer, or download them
#' all as zip files and then optionally unzip them.
#'
#' @param gh_user Character string. A GitHub user name.
#' @param dest_dir Character string. A local file path where the clones or
#'     zipped repositories will be downloaded to. Must be a full path.
#' @param copy_type Character string. Specify whether to \code{"download"}
#'     or \code{"clone"} the repos to your local machine.
#' @param protocol Character string. Either \code{"https"} or \code{"ssh"}. Only
#'     required if \code{copy_type = "clone"}.
#'
#' @details Make sure you've got a GitHub account and have
#'     \href{https://happygitwithr.com/github-pat.html}{generated a GitHub PAT}
#'     and stored it your .Renviron. If you're using \code{protocol = "ssh"},
#'     you need to make sure you have \href{https://happygitwithr.com/ssh-keys.html}{set up your SSH keys}.
#'
#' @return GitHub repositories either (a) cloned or (b) downloaded in the
#'     specified local directory.
#'
#' @export
#'
#' @examples
#' \dontrun{
#' ghd_copy(
#'   gh_user = "matt-dray",
#'   dest_dir = "~/Documents/repos-cloned",
#'   copy_type = "clone",
#'   protocol = "https"
#' )
#'
#' ghd_copy(
#'   gh_user = "matt-dray",
#'   dest_dir = "~/Documents/repos-downloaded",
#'   copy_type = "download"
#' )
#' }
ghd_copy <- function(gh_user, dest_dir, copy_type, protocol = NULL) {

  if (is.character(gh_user) == FALSE) {
    stop("Argument gh_user must be a character string that's a GitHub user.\n")
  }

  if (is.character(dest_dir) == FALSE) {
    stop("Argument dest_dir must be a character string that represents a file path.\n")
  }

  if (!copy_type %in% c("download", "clone")) {
    stop("Argument copy_type must be 'clone' or 'download'.\n")
  }

  if (copy_type == "clone" & is.null(protocol)) {
    stop("You must provide either 'https' or 'ssh' to the protocol argument.")
  }

  if (copy_type == "clone" & !protocol %in% c("https", "ssh")) {
    stop("You must provide either 'https' or 'ssh' to the protocol argument.")
  }

  if (copy_type == "download" & !is.null(protocol)) {
    warning("You don't need the protocol argument for downloads. Did you mean to clone instead?")
  }

  # Get repo info for the user
  gh_response <- ghd_get_repos(gh_user)

  # Get a vector of the repo names
  names_vec <- ghd_extract_names(gh_response)

  # Check if directory exists; ask user if they want to create it
  if (!isTRUE(dir.exists(dest_dir))) {

    # Ask user to create directory if it doesn't exist
    q_create_dir <- readline(
      prompt = paste0("Create new directory at path ", dest_dir, "? y/n: ")
    )

    # Create the directory if 'yes'
    if (substr(tolower(q_create_dir), 1, 1) == "y") {

      # Create the directory
      dir.create(path = dest_dir)

    } else if (substr(tolower(q_create_dir), 1, 1) == "n") {

      stop("Aborted by user choice. Retry with another repo.\n")

    } else {

      stop("Aborted. Input not understood.\n")

    }

  }

  # Control flow for copy_type

  if (copy_type == "clone") {  # if cloning

    ghd_clone_multi(gh_user, names_vec, protocol, dest_dir)

    cat("Finished cloning\n")

  } else if (copy_type == "download") {  # if downloading

    # Make data frame of zip URLs for each repo
    repos_df <- ghd_enframe_urls(names_vec, gh_user)

    # Download the zips to the specified location
    ghd_download_zips(repos_df, dest_dir)

    # Ask if all should be unzipped
    q_unzip <- readline("Unzip all folders? y/n: ")

    if (substr(tolower(q_unzip), 1, 1) == "y") {

      # Unzip the files
      ghd_unzip(dest_dir)

    } else if (substr(tolower(q_unzip), 1, 1) == "n") {

      cat("The downloaded directories will not be unzipped.\n")

    } else {

      cat(
        "Input not understood. The downloaded directories will not be unzipped.\n",
        "See ?ghdump:::ghd_unzip() to unzip the directories yourself.\n"
      )

    }

    cat("Finished downloading\n")

  }

}
