<img src="https://raw.githubusercontent.com/matt-dray/stickers/master/output/ghdump_hex.png" width="150" align="right">

# ghdump

<!-- badges: start -->
[![Project Status: Inactive – The project has reached a stable, usable state but is no longer being actively developed; support/maintenance will be provided as time allows.](https://www.repostatus.org/badges/latest/inactive.svg)](https://www.repostatus.org/#inactive)
[![R-CMD-check](https://github.com/matt-dray/ghdump/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/matt-dray/ghdump/actions/workflows/R-CMD-check.yaml)
[![rostrum.blog
post](https://img.shields.io/badge/rostrum.blog-post-008900?style=flat&labelColor=black&logo=data:image/gif;base64,R0lGODlhEAAQAPEAAAAAABWCBAAAAAAAACH5BAlkAAIAIf8LTkVUU0NBUEUyLjADAQAAACwAAAAAEAAQAAAC55QkISIiEoQQQgghRBBCiCAIgiAIgiAIQiAIgSAIgiAIQiAIgRAEQiAQBAQCgUAQEAQEgYAgIAgIBAKBQBAQCAKBQEAgCAgEAoFAIAgEBAKBIBAQCAQCgUAgEAgCgUBAICAgICAgIBAgEBAgEBAgEBAgECAgICAgECAQIBAQIBAgECAgICAgICAgECAQECAQICAgICAgICAgEBAgEBAgEBAgICAgICAgECAQIBAQIBAgECAgICAgIBAgECAQECAQIBAgICAgIBAgIBAgEBAgECAgECAgICAgICAgECAgECAgQIAAAQIKAAAh+QQJZAACACwAAAAAEAAQAAAC55QkIiESIoQQQgghhAhCBCEIgiAIgiAIQiAIgSAIgiAIQiAIgRAEQiAQBAQCgUAQEAQEgYAgIAgIBAKBQBAQCAKBQEAgCAgEAoFAIAgEBAKBIBAQCAQCgUAgEAgCgUBAICAgICAgIBAgEBAgEBAgEBAgECAgICAgECAQIBAQIBAgECAgICAgICAgECAQECAQICAgICAgICAgEBAgEBAgEBAgICAgICAgECAQIBAQIBAgECAgICAgIBAgECAQECAQIBAgICAgIBAgIBAgEBAgECAgECAgICAgICAgECAgECAgQIAAAQIKAAA7)](https://www.rostrum.blog/2020/06/14/ghdump/)

<!-- badges: end -->

## Purpose

Clone all of a GitHub user's repositories, or download them as zip files (and optionally unzip them). Intended for archiving purposes or setting up on a new computer.

## Using {ghdump}

Note that the package does what I need it to do, but is not fully tested for all systems and set-ups. Please [file an issue](https://github.com/matt-dray/ghdump/issues) or raise a pull request if you have a problem or contribution. You can also learn more about this package from [an associated blog post](https://www.rostrum.blog/2020/06/14/ghdump/). 

[The {gitcellar} package](https://docs.ropensci.org/gitcellar/) later appeared on rOpenSci by Maëlle Salmon and Jeroen Ooms. They're very smart, so you might want to check it out. It has a `keep` function that allows you to select only certain repos ({ghdump} doesn't have this feature).

### Install

You can install {ghdump} from GitHub with:

``` r
install.packages("remotes")  # if not yet installed
remotes::install_github("matt-dray/ghdump")
```

### GitHub PAT

You'll need a GitHub Personal Access Token (PAT) to use {ghdump}.

Assuming you have a GitHub account, generate a token for accessing the GitHub API and store this in your .Renviron file. The {usethis} package helps make this a breeze. Read more in the [Happy Git and GitHub for the useR](https://happygitwithr.com/github-pat.html) book by Jenny Bryan, the STAT 545 TAs and Jim Hester.

``` 
usethis::browse_github_pat()  # opens browser to generate token
usethis::edit_r_environ()     # add your token to the .Renviron
```

Make sure to restart R after these steps.

### Use `ghd_copy()`

{ghdump} has one exported function: `ghd_copy()`. Pass to the function a GitHub user name, a local directory to download into, and whether you want to download or clone the repos. If you want to clone, you must [specify the protocol](https://docs.github.com/en/github/using-git/which-remote-url-should-i-use) (make sure [your keys are set up](https://happygitwithr.com/ssh-keys.html) if specifying SSH).

To clone:

``` r
ghdump::ghd_copy(
  gh_user = "matt-dray",  # user whose repos to download
  dest_dir = "~/Documents/repos",  # where to copy to
  copy_type = "clone",  # 'clone' or 'download' the repos
  protocol = "https"  # 'https' or 'ssh'
)
```

To download:

``` r
ghdump::ghd_copy(
  gh_user = "matt-dray",
  dest_dir = "~/Documents/repos",
  copy_type = "download"
)
```

The function is designed to be used interactively and infrequently. To this end, the user is prompted throughout as to whether to:

* create a new local directory with the provided 'dest_dir' argument
* commit to cloning all the repos (if `copy_type = "clone"`) 
* commit to downloading all zip files  (if `copy_type = "download"`) and then whether to:
    * unzip all the files
    * retain the zip files
    * rename the unzipped directories to remove the default branch suffix (e.g. '-master')

## Credits

The function interacts with the GitHub API thanks to [the {gh} package](https://github.com/r-lib/gh) by Gábor Csárdi, Jenny Bryan and Hadley Wickham. Iteration is thanks to [the {purrr} package](https://purrr.tidyverse.org/) by Lionel Henry and Hadley Wickham. [The {cli} package](https://cli.r-lib.org/) by Gábor Csárdi allowed for a prettier user interface.

The {ghdump} package sticker was made thanks to Dmytro Perepolkin's [{bunny}](https://github.com/dmi3kno/bunny) package and the [{magick} package](https://cran.r-project.org/web/packages/magick/vignettes/intro.html) from Jeroen Ooms.

## Code of Conduct
  
Please note that the {ghdump} project is released with a [Contributor Code of Conduct](https://contributor-covenant.org/version/2/0/CODE_OF_CONDUCT.html). By contributing to this project, you agree to abide by its terms.
