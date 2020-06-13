
#' Get GitHub Repo Information for a Named User
#'
#' Uses \code{\link[gh]{gh}} to access the GitHub API and get the details for
#' all of a named user;s repos. To use this function you need to have created a
#' GitHub account and to have put a GitHub Personal Access Token (PAT) in your
#' .Renviron. See \href{https://happygitwithr.com/github-pat.html}{Happy Git and GitHub for the UseR}
#' for omre information.
#'
#' @param gh_user Character string. A GitHub username.
#'
#' @return A gh_response object.
get_repos <- function(gh_user) {

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
#' @param repo_object A gh_response object, as returned by \code{\link{get_repos}}.
#'
#' @return A character vector of GitHub repo names.
extract_repo_names <- function(repo_object) {

  repo_names <-
    purrr::map(
      .x = repo_object,
      .f = purrr::pluck("name")
    ) %>%
    unlist()

  repo_count <- length(repo_names)

  cat(repo_count, "repos found\n")

  return(repo_names)

}

#' Create A Data Frame Of Repo Names And Zip File URLS For Each
#'
#' Prepare a data frame containing each repo name and its corresponding zip file
#' URL in the form https://github.com/username/reponame/archive/master.zip
#'
#' @param repo_names A character vector of GitHub repository names, as returned
#'     by \code{\link{extract_repo_names}}.
#' @param gh_user The name of a GitHub user.
#'
#' @return A tibble/data.frame object. One row per GitHub repo with character
#'     vector columns for the repo_name and zip_url.
enframe_repo_urls <- function(repo_names, gh_user) {

  repo_urls <-
    repo_names %>%
    tibble::enframe(name = NULL, value = "repo_name") %>%
    dplyr::mutate(
      zip_url = paste0(
        "https://github.com/", gh_user, "/", repo_name, "/archive/master.zip"
      )
    )

  return(repo_urls)

}

#' Download Zipped Repos To Your Machine
#'
#' Download to a specified location the zip files from provided URL. The
#' directory is created if it doesn't already exist.
#'
#' @param repo_urls A tibble/data.frame as returned by
#'     \code{\link{enframe_repo_urls}}, with one row per GitHub repo with
#'     character-class columns for the repo_name and zip_url.
#' @param dest_dir A character string. The local directory you want to download
#'     the zipped files to.
#'
#' @return Zipped GitHub repositories downloaded to a (possibly new) directory.
download_repo_zips <- function(repo_urls, dest_dir) {

  # Create dest_dir if it doesn't already exist
  if (!isTRUE(dir.exists(dest_dir))) {
    cat("Creating new directory:", dest_dir, "\n")
    dir.create(path = dest_dir)
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
  cat("Downloading zipped repositories to", dest_dir, "\n")
  purrr::walk2(
    .x = repo_urls$zip_url,
    .y = repo_urls$repo_name,
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
#'     \code{\link{download_repo_zips}}.
#' @param rm_zip Logical. Having unzipped the files, should the zipped versions
#'     be deleted?
#' @param rename_dir Logical. Should the unzipped files be renamed to remove the
#'     "-master" suffix?
#'
#' @return Unzipped GitHub repositories in a named directory.
unzip_repos <- function(dir, rm_zip = TRUE, rename_dir = TRUE) {

  # Paths to each zip file
  zip_files <-
    list.files(
      path = dir,
      pattern = "*.zip",
      full.names = TRUE
    )

  # Unzip the files
  cat("Unzipping repositories\n")
  purrr::walk(
    .x = zip_files,
    .f = ~ utils::unzip(zipfile = .x, exdir = dir)
  )

  # Remove the zip files
  if (isTRUE(rm_zip)) {
    cat("Removing zipped folders\n")
    purrr::walk(
      .x = zip_files,
      .f = file.remove
    )
  }

  # Remove the "-master" bit of the unzipped files
  if (isTRUE(rename_dir)) {

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
        to = stringr::str_remove(
          string = unzipped_dirs,
          pattern = "-master"
        )
      )

    # Rename each file to remove "-master"
    cat("Renaming files to remove '-master' suffix\n")
    purrr::walk2(
      .x = rename_df$from,
      .y = rename_df$to,
      .f = file.rename
    )

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
#' download_all(gh_user = "matt-dray", dir = "~/Documents/repos")
#' }
download_all <- function(gh_user, dir) {

  gh_response <- get_repos(gh_user)
  names_vec <- extract_repo_names(gh_response)
  repos_df <- enframe_repo_urls(names_vec, gh_user)
  download_repo_zips(repos_df, dir)
  unzip_repos(dir)
  cat("Finished\n")

}
