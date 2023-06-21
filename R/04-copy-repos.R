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
#'     you need to make sure you have
#'     \href{https://happygitwithr.com/ssh-keys.html}{set up your SSH keys}.
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

  if (!is.character(gh_user)) {
    cli::cli_abort(
      c(
        "Argument 'gh_user' must be a character string that's a GitHub user's profile name.",
        "i" = "You provided an object of class {class(gh_user)}."
      )
    )
  }

  if (!is.character(dest_dir)) {
    cli::cli_abort(
      c(
        "Argument 'dest_dir' must be a character string that represents a file path.",
        "i" = "You provided an object of class {class(dest_dir)}."
      )
    )
  }

  if (!copy_type %in% c("download", "clone")) {
    cli::cli_abort(
      c(
        "Argument 'copy_type' must be 'clone' or 'download'.",
        "i" = "You provided '{copy_type}'."
      )
    )
  }

  if (copy_type == "clone" & is.null(protocol)) {
    cli::cli_abort(
      c(
        "Argument 'protocol' must be 'https' or 'ssh'.",
        "i" = "You provided '{protocol}'."
      )
    )
  }

  if (copy_type == "clone" && !protocol %in% c("https", "ssh")) {
    cli::cli_abort(
      c(
        "Argument 'protocol' must be 'https' or 'ssh'.",
        "i" = "You provided '{protocol}'."
      )
    )
  }

  if (copy_type == "download" & !is.null(protocol)) {
    cli::cli_alert_warning(
      paste(
        "You don't need the 'protocol' argument for downloads.",
        "Did you mean to clone instead?"
      )
    )

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

    is_yes <- substr(tolower(q_create_dir), 1, 1) == "y"
    is_no <- substr(tolower(q_create_dir), 1, 1) == "n"

    # Create the directory if 'yes'
    if (is_yes) {

      # Create the directory
      dir.create(path = dest_dir)

    } else if (is_no) {

      cli::cli_abort("Aborted by user choice. Retry with another repo.")

    } else {

      cli::cli_abort("Aborted. Input not understood.")

    }

  }

  # Control flow for copy_type

  if (copy_type == "clone") {  # if cloning

    ghd_clone_multi(gh_user, names_vec, protocol, dest_dir)

    cli::cli_alert_success("Finished cloning.")

  } else if (copy_type == "download") {  # if downloading

    # Make data frame of zip URLs for each repo
    repos_df <- ghd_enframe_urls(names_vec, gh_user)

    # Download the zips to the specified location
    ghd_download_zips(repos_df, dest_dir)

    # Ask if all should be unzipped
    q_unzip <- readline("Unzip all folders? y/n: ")
    is_yes <- substr(tolower(q_unzip), 1, 1) == "y"
    is_no <- substr(tolower(q_unzip), 1, 1) == "n"

    if (is_yes) {

      # Unzip the files
      ghd_unzip(dest_dir)

    } else if (is_no) {

      cli::cli_alert_info("The downloaded directories will not be unzipped.")

    } else {

      cli::cli_alert_warning(
        "Input not understood. The downloaded directories will not be unzipped."
      )

      cli::cli_alert_info(
        "See ?ghdump:::ghd_unzip() to unzip the directories yourself."
      )

    }

    cli::cli_alert_success("Finished downloading.")

  }

}
