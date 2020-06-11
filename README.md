
# allghrepos

<!-- badges: start -->
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
<!-- badges: end -->

## Purpose

Download all of a GitHub user's repositories as zip files to a specified location and unzip them. Intended for archiving or setting up a new computer.

Works thanks to [the {gh} package](https://github.com/r-lib/gh) by Gábor Csárdi, Jenny Bryan and Hadley Wickham.

## Install

You can install the devloper version of {allghrepos} from GitHub with:

``` r
remotes::install_github("matt-drayallghrepos")
```

## Example

Assuming you have a GitHub account, generate a token for accessing the GitHub API and store this in your .Renviron file. The {usethis} package helps make this a breeze. Read more in the [Happy Git and GitHub for the useR](https://happygitwithr.com/github-pat.html) book by Jenny Bryan, the STAT 545 TAs and Jim Hester.

```
library(usethis)
browse_github_pat()  # opens browser to generate token
edit_r_environ()     # add your token to the .Renviron
```

The simplest use of the {allghrepos} package is to pass to the `download_all()` function a GitHub user name and a local directory to download into. The zipped repos will be downloaded and unzipped.

``` r
library(allghrepos)

download_all(
  gh_user = "matt-dray",     # user whose repos to download
  dir = "~/Documents/repos"  # where to download to
)
```

## Code of Conduct
  
  Please note that the allghrepos project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
