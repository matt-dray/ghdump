
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
#'     the zipped files to.
#'
#' @return Zipped GitHub repositories downloaded to a (possibly new) directory.
ghd_download_zips <- function(repo_urls, dest_dir) {

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
      stop("Aborted by user choice. Please choose a different directory.")
    } else {
      stop("Aborted. Input not understood.")
    }

  }

  # Ask if all the repos should be downloaded
  q_download_all <- readline(
    prompt = paste0("Download all ", nrow(repo_urls), " repos? y/n: ")
  )

  if (q_download_all %in% affirm) {
    cat("Downloading zipped repositories to", dest_dir, "\n")
  } else if (q_download_all %in% deny) {
    stop("Aborted by user choice.")
  } else {
    stop("Aborted. Input not understood.")
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
#'     \code{\link{ghd_download_zips}}.
#'
#' @return Unzipped GitHub repositories in a named directory.
ghd_unzip <- function(dir) {

  # Accepted strings as answers from users
  affirm <- c("y", "Y", "yes", "Yes", "YES")
  deny <- c("n", "N", "no", "No", "NO")

  # Paths to each zip file
  zip_files <-
    list.files(
      path = dir,
      pattern = "*.zip$",
      full.names = TRUE
    )

  # Unzip the files
  cat("Unzipping repositories\n")
  purrr::walk(
    .x = zip_files,
    .f = ~ utils::unzip(zipfile = .x, exdir = dir)
  )

  # Ask if the zip files should be retained
  q_keep_zip <- readline(
    prompt = paste0("Retain the zip files? y/n: ")
  )

  if (q_keep_zip %in% affirm) {
    cat("Keeping zipped folders.")
  } else if (q_keep_zip %in% deny) {

    cat("Removing zipped folders\n")

    purrr::walk(
      .x = zip_files,
      .f = file.remove
    )

  } else {
    cat("Input not understood. Keeping zipped folders.")
  }


  # Ask if "-master" suffix of unzipped files should be replaced
  q_remove_suffix <- readline(
    prompt = paste0(
      "Remove '-master' suffix from unzipped directory names? y/n: "
    )
  )

  if (q_remove_suffix %in% affirm) {

    # Paths of each unzipped file
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
        to = gsub(pattern = "-master", replacement = "", x = unzipped_dirs),
        stringsAsFactors = FALSE
      )

    # Rename each file to remove "-master"
    cat("Renaming files to remove '-master' suffix\n")
    purrr::walk2(
      .x = rename_df$from,
      .y = rename_df$to,
      .f = file.rename
    )


  } else if (q_remove_suffix %in% deny) {
    cat("Unzipped repository names unchanged.")
  } else {
    cat("Input not understood. Leaving unzipped repository names unchanged.")
  }

}

#' Download All GitHub Repositories For A User
#'
#' Download all of a GitHub user's repositories to your computer as zip files
#' and then optionally unzip them. Make sure you've got a GitHub account and
#' have generated a GitHub PAT token and stored it your .Renviron. See
#' package README for details.
#'
#' @param gh_user Character string. A GitHub user name.
#' @param dir Character string. A local file path where the zipped repositories
#'     will be downloaded to.
#'
#' @return Unzipped GitHub repositories in a specified local directory.
#' @export
#'
#' @examples
#' \dontrun{
#' ghd_download(gh_user = "matt-dray", dir = "~/Documents/repos")
#' }
ghd_download <- function(gh_user, dir) {

  # Accepted strings as answers from users
  affirm <- c("y", "Y", "yes", "Yes", "YES")
  deny <- c("n", "N", "no", "No", "NO")

  gh_response <- ghd_get_repos(gh_user)

  names_vec <- ghd_extract_names(gh_response)

  repos_df <- ghd_enframe_urls(names_vec, gh_user)

  ghd_download_zips(repos_df, dir)

  q_unzip <- readline("Unzip all folders? y/n: ")
  if (q_unzip %in% affirm) {
    ghd_unzip(dir)
  } else if (q_download_all %in% deny) {
    cat("Directories will not be unzipped.")
  } else {
    cat("Input not understood. Directories will not be unzipped. Run ghdump:::ghd_unzip() if you change your mind.")
  }

  cat("Finished\n")

}
