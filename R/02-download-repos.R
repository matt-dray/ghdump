# Purpose: download and optionally unzip and rename repos

#' Create A Data Frame Of Repo Names And Zip File URLS For Each
#'
#' Prepare a data frame containing each repo name and its corresponding zip file
#' URL in the form https://github.com/username/reponame/archive/master.zip
#'
#' @param repo_names A character vector of GitHub repository names, as returned
#'     by \code{\link{ghd_extract_names}}.
#' @param gh_user The name of a GitHub user.
#'
#' @return A data.frame object. One row per GitHub repo with character
#'     vector columns for the repo_names and zip_url.
ghd_enframe_urls <- function(repo_names, gh_user) {

  repos_df <- as.data.frame(repo_names)

  repos_df$zip_url <- paste0(
    "https://github.com/", gh_user, "/", repo_names, "/archive/master.zip"
  )

  return(repos_df)

}

#' Download Zipped Repos To Your Machine
#'
#' Download to a specified location the zip files from provided URL. The
#' directory is created if it doesn't already exist.
#'
#' @param repo_urls A data.frame as returned by
#'     \code{\link{ghd_enframe_urls}}, with one row per GitHub repo with
#'     character-class columns for the repo_names and zip_url.
#' @param dest_dir A character string. The local directory you want to download
#'     the zipped files to. Must be a full path.
#'
#' @return Zipped GitHub repositories downloaded to a (possibly new) directory.
ghd_download_zips <- function(repo_urls, dest_dir) {

  # Ask if all the repos should be downloaded
  q_download_all <- readline(
    prompt = paste0(
      "Definitely download all ", nrow(repo_urls), " repos? y/n: "
    )
  )

  is_yes <- substr(tolower(q_download_all), 1, 1) == "y"
  is_no <- substr(tolower(q_download_all), 1, 1) == "n"

  if (is_yes) {

    cli::cli_alert_info("Downloading zipped repositories to {dest_dir}")
    cli::cli_alert_info("Hit ESC at any time to abort.")

  } else if (is_no) {

    cli::cli_abort("Aborted by user choice.")

    stop("Aborted by user choice.\n")

  } else {

    cli::cli_abort("Aborted. Input not understand.")

  }

  # Prepare safe file download (passes over failures)
  download_safely <-
    purrr::safely(
      ~ download.file(
        url = .x,
        destfile = paste0(dest_dir, "/", .y, ".zip"),
        mode = "wb"
      )
    )

  # Download the zip files for each repo name
  purrr::walk2(
    .x = repo_urls$zip_url,
    .y = repo_urls$repo_names,
    .f = download_safely
  )

}

#' Unzip GitHub Repositories In A Named Directory
#'
#' Unzips the GitHub repositories that have been downloaded to a specified
#' local directory and optionally deletes the zipped versions. Optionally
#' rename all the unzipped folders to remove the "-master" suffix (e.g.
#' "demo-repo-master" becomes "demo-repo").
#'
#' @param dir A string. Path to a local directory containing zipped GitHub
#'     directories. These may have been downloaded using
#'     \code{\link{ghd_download_zips}}. Must be a full path.
#'
#' @return Unzipped GitHub repositories in a named directory.
ghd_unzip <- function(dir) {

  # Paths to each zip file
  zip_files <-
    list.files(
      path = dir,
      pattern = "*.zip$",
      full.names = TRUE
    )

  # Unzip the files
  cli::cli_alert_info("Unzipping repositories.")
  purrr::walk(
    .x = zip_files,
    .f = ~ utils::unzip(zipfile = .x, exdir = dir)
  )

  # Ask if the zip files should be retained
  q_keep_zip <- readline(
    prompt = paste0("Retain the zip files? y/n: ")
  )

  is_yes <- substr(tolower(q_keep_zip), 1, 1) == "y"
  is_no <- substr(tolower(q_keep_zip), 1, 1) == "n"

  # React to user input
  if (is_yes) {

    cli::cli_alert_info("Keeping zipped folders.")

  } else if (is_no) {

    cli::cli_alert_info("Removing zipped folders.")

    purrr::walk(
      .x = zip_files,
      .f = file.remove
    )

    cli::cli_alert_success("Removed zipped folders.")

  } else {

    cli::cli_alert_warning("Input not understood. Keeping zipped folders.")

  }


  # Ask if "-master" suffix of unzipped files should be replaced
  q_remove_suffix <- readline(
    prompt = paste0(
      "Remove branch suffix (e.g. '-main') from unzipped directory names? y/n: "
    )
  )

  is_yes <- substr(tolower(q_remove_suffix), 1, 1) == "y"
  is_no <- substr(tolower(q_remove_suffix), 1, 1) == "n"

  # React to user input
  if (is_yes) {

    # Get paths of each unzipped file
    unzipped_dirs <-
      list.dirs(
        path = dir,
        recursive = FALSE,
        full.names = TRUE
      )

    # Data frame of repo file names and what to rename them to
    rename_df <-
      data.frame(
        from = unzipped_dirs,
        to = gsub(pattern = "-.*$", replacement = "", x = unzipped_dirs),
        stringsAsFactors = FALSE
      )

    # Rename each file to remove "-master"
    cli::cli_alert_info("Renaming files to remove branch suffix.")
    purrr::walk2(
      .x = rename_df$from,
      .y = rename_df$to,
      .f = file.rename
    )
    cli::cli_alert_success("Renamed folders.")

  } else if (is_no) {

    cli::cli_alert_info("Unzipped repository names unchanged.")

  } else {

    cli::cli_alert_warning(
      "Input not understood. Leaving unzipped repository names unchanged."
    )

  }

}
