
# Get repo details for a user
# Returns a gh_response/list object
get_repos <- function(gh_user) {

  user_repos <-
    gh::gh(
      endpoint = "/users/:username/repos",
      username = gh_user,
      .limit = Inf  # get all repos
    )

  return(user_repos)

}

# Extract the names of a user's repo from the  gh_response/list object
# Returns a vector
extract_repo_names <- function(repo_object) {

  repo_names <-
    purrr::map(
      .x = repo_object,
      .f = purrr::pluck("name")
    ) %>%
    unlist()

  return(repo_names)

}

# Generate URLs to zip files of each repo
# Returns a dataframe, one row per repo
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

# Download the repo zip files to a specified destination
download_repo_zips <- function(repo_urls, dest_dir) {

  # Create dest_dir if ti doesn't already exist
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

# Unzip files, potentially remove them and remove "-master" from file names
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
#' @return Unzipped folders in the specified directory.
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
