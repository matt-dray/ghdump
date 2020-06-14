
# ghdump

<!-- badges: start -->
[![Project Status: WIP – Initial development is in progress, but there has not yet been a stable, usable release suitable for the public.](https://www.repostatus.org/badges/latest/wip.svg)](https://www.repostatus.org/#wip)
[![rostrum.blog
post](https://img.shields.io/badge/rostrum.blog-post-008900?style=flat&labelColor=black&logo=data:image/gif;base64,R0lGODlhEAAQAPEAAAAAABWCBAAAAAAAACH5BAlkAAIAIf8LTkVUU0NBUEUyLjADAQAAACwAAAAAEAAQAAAC55QkISIiEoQQQgghRBBCiCAIgiAIgiAIQiAIgSAIgiAIQiAIgRAEQiAQBAQCgUAQEAQEgYAgIAgIBAKBQBAQCAKBQEAgCAgEAoFAIAgEBAKBIBAQCAQCgUAgEAgCgUBAICAgICAgIBAgEBAgEBAgEBAgECAgICAgECAQIBAQIBAgECAgICAgICAgECAQECAQICAgICAgICAgEBAgEBAgEBAgICAgICAgECAQIBAQIBAgECAgICAgIBAgECAQECAQIBAgICAgIBAgIBAgEBAgECAgECAgICAgICAgECAgECAgQIAAAQIKAAAh+QQJZAACACwAAAAAEAAQAAAC55QkIiESIoQQQgghhAhCBCEIgiAIgiAIQiAIgSAIgiAIQiAIgRAEQiAQBAQCgUAQEAQEgYAgIAgIBAKBQBAQCAKBQEAgCAgEAoFAIAgEBAKBIBAQCAQCgUAgEAgCgUBAICAgICAgIBAgEBAgEBAgEBAgECAgICAgECAQIBAQIBAgECAgICAgICAgECAQECAQICAgICAgICAgEBAgEBAgEBAgICAgICAgECAQIBAQIBAgECAgICAgIBAgECAQECAQIBAgICAgIBAgIBAgEBAgECAgECAgICAgICAgECAgECAgQIAAAQIKAAA7)](https://www.rostrum.blog/2020/06/14/ghdump/)
<!-- badges: end -->

## Purpose

Download all of a GitHub user's repositories as zip files to a specified location and unzip them. Intended for archiving or setting up a new computer.

Works thanks to [the {gh} package](https://github.com/r-lib/gh) by Gábor Csárdi, Jenny Bryan and Hadley Wickham.

## Using {ghdump}

Learn more about this package from [an associated blog post](https://www.rostrum.blog/2020/06/14/ghdump/).

### GitHub PAT

Assuming you have a GitHub account, generate a token for accessing the GitHub API and store this in your .Renviron file. The {usethis} package helps make this a breeze. Read more in the [Happy Git and GitHub for the useR](https://happygitwithr.com/github-pat.html) book by Jenny Bryan, the STAT 545 TAs and Jim Hester.

```
usethis::browse_github_pat()  # opens browser to generate token
usethis::edit_r_environ()     # add your token to the .Renviron
```

Make sure to restart R after these steps.

### Install

You can install the developer version of {ghdump} from GitHub with:

``` r
remotes::install_github("matt-dray/ghdump")
```

### Use `ghd_download()`

{ghdump} has one exported function: `ghd_download()`. Pass to the function a GitHub user name and a local directory to download into. 

``` r
ghdump::ghd_download(
  gh_user = "matt-dray",     # user whose repos to download
  dir = "~/Documents/repos"  # where to download to
)
```

The function is designed to be used interactively and infrequently. To this end, the user is prompted throughout as to whether to:

* create a new local directory with the provided 'dir' argument
* download all zip files
* unzip all the files
* retain the zip files
* rename the unzipped directories to remove the default '-master' suffix provided on download

## Code of Conduct
  
Please note that the {ghdump} project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
