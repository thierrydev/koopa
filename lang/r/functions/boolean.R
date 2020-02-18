#' Can we use cli methods?
#' @note Updated 2020-02-16.
hasCli <- function() {
    isInstalled("cli")
}



#' Can we output color to the console?
#' @note Updated 2020-02-16.
hasColor <- function() {
    isInstalled("crayon")
}



#' Does the current session have a GitHUB personal access token?
#'
#' Required for package installs from GitHub, otherwise will hit rate limit.
#'
#' @note Updated 2020-02-18.
hasGitHubPAT <- function() {
    isTRUE(nzchar(Sys.getenv("GITHUB_PAT")))
}



#' Is a system command installed?
#' @note Updated 2020-02-06.
isCommand <- function(which) {
    nzchar(Sys.which(which))
}



#' Is flag?
#' @note Updated 2020-02-06.
isFlag <- function(x) {
    is.logical(x) &&
        !any(is.na(x)) &&
        identical(length(x), 1L)
}



#' Is an R package installed?
#' @note Updated 2020-02-16.
isInstalled <- function(pkgs) {
    stopifnot(requireNamespace("utils", quietly = TRUE))
    # Note that GitHub packages are "user/repo", so use basename.
    basename(pkgs) %in% rownames(installed.packages())
}



#' Is macOS?
#' @note Updated 2020-02-07.
isMacOS <- function() {
    grepl(pattern = "darwin", x = R.Version()[["os"]])
}



#' Is string?
#' @note Updated 2020-02-09.
isString <- function(x) {
    is.character(x) &&
        !any(is.na(x)) &&
        identical(length(x), 1L) &&
        isTRUE(nzchar(x))
}