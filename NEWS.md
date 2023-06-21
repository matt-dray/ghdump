# ghdump 0.1.0

* Added {cli} for a prettier user interface and added new messages.
* Fixed bug where providing a protocol borked downloads (#14).
* Attempted to remove branch name from unzipped file folders by simple regex (`-.*$`) rather than to remove the hard-coded '-master'.
* Added R-CMD check GitHub Action.
* Bump v0.1.0.

# ghdump 0.0.0.9006

* Added protocol argument for user to choose HTTPS or SSH (#10)

# ghdump 0.0.0.9005

* Altered system call when cloning to work on Windows (#9)

# ghdump 0.0.0.9004

* Breaking: renamed ghd_download() to ghd_copy()
* Introduced cloning functionality for (at least) Mac (#6)
* Updated readme given new functionality
* Separated scripts in `r/` into different files
* Made minor improvements to code comments and user prompt text
* Preferred ?readlines() example for 'y'/'n' user input
* Added license

# ghdump 0.0.0.9003

* Fixed error when unzipping answer is 'no' (#5)
* Updated readme to be clear about archival use

# ghdump 0.0.0.9002

* Remove all dependencies except {gh} and {purrr}
* Make `ghd_download()` more interactive by asking user questions with `readlines()`
* Update documentation

# ghdump 0.0.0.9001

* Renamed to {ghdump}
* Replaced mentions of old package name
* Added package doc

# ghdump 0.0.0.9000

* Set up package
* Aded readme
* Added R file and documented functions
* Added license
* Added code of conduct
* Added news
