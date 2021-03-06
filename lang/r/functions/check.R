#' Check failure
#'
#' Set a system environment variable that we can detect in `koopa check`.
#'
#' @note Updated 2020-02-27.
#' @noRd
checkFail <- function() {
    Sys.setenv("KOOPA_CHECK_FAIL" = 1L)
}



#' Check Homebrew Cask version
#'
#' @note Updated 2020-02-12.
#' @noRd
#'
#' @examples
#' currentHomebrewCaskVersion("gpg-suite")
checkHomebrewCaskVersion <- function(name) {
    invisible(vapply(
        X = name,
        FUN = function(name) {
            checkVersion(
                name = name,
                whichName = NA,
                current = currentHomebrewCaskVersion(name),
                expected = expectedHomebrewCaskVersion(name)
            )
        },
        FUN.VALUE = logical(1L)
    ))
}



#' Check macOS app version
#'
#' @note Updated 2020-04-09.
#' @noRd
#'
#' @examples
#' currentMacOSAppVersion(c("BBEdit", "iTerm"))
checkMacOSAppVersion <- function(name) {
    invisible(vapply(
        X = name,
        FUN = function(name) {
            checkVersion(
                name = name,
                whichName = NA,
                current = currentMacOSAppVersion(name),
                expected = expectedMacOSAppVersion(name)
            )
        },
        FUN.VALUE = logical(1L)
    ))
}



#' Check version
#' @note Updated 2020-04-09.
#' @noRd
checkVersion <- function(
    name,
    whichName,
    current,
    expected,
    eval = c("==", ">="),
    required = TRUE
) {
    stopifnot(
        requireNamespace("goalie", quietly = TRUE),
        requireNamespace("acidbase", quietly = TRUE)
    )
    if (missing(whichName)) {
        whichName <- name
    }
    if (identical(current, character())) {
        current <- NA_character_
    }
    stopifnot(
        goalie::isString(name),
        goalie::isString(whichName) ||
            is.na(whichName),
        is(current, "numeric_version") ||
            goalie::isString(current) ||
            is.na(current),
        is(expected, "numeric_version") ||
            goalie::isString(expected) ||
            is.na(expected),
        goalie::isFlag(required)
    )
    eval <- match.arg(eval)
    statusList <- status()
    if (isTRUE(required)) {
        fail <- statusList[["fail"]]
    } else {
        fail <- statusList[["note"]]
    }
    ## Check to see if program is installed.
    if (is.na(current)) {
        if (isTRUE(required)) {
            checkFail()
        }
        message(sprintf(
            fmt = "  %s | %s is not installed.",
            fail, name
        ))
        return(invisible(FALSE))
    }
    ## Normalize the program path, if applicable.
    if (is.na(whichName)) {
        which <- NA_character_
    } else {
        which <- unname(Sys.which(whichName))
        stopifnot(isTRUE(nzchar(which)))
    }
    ## Sanitize the version for non-identical (e.g. GTE) comparisons.
    if (!identical(eval, "==")) {
        if (grepl("\\.", current)) {
            current <- acidbase::sanitizeVersion(current)
            current <- package_version(current)
        }
        if (grepl("\\.", expected)) {
            expected <- acidbase::sanitizeVersion(expected)
            expected <- package_version(expected)
        }
    }
    ## Compare current to expected version.
    if (eval == ">=") {
        ok <- current >= expected
    } else if (eval == "==") {
        ok <- current == expected
    }
    if (isTRUE(ok)) {
        status <- statusList[["ok"]]
    } else {
        if (isTRUE(required)) {
            checkFail()
        }
        status <- fail
    }
    msg <- sprintf(
        fmt = "  %s | %s (%s %s %s)",
        status, name,
        current, eval, expected
    )
    if (!is.na(which)) {
        msg <- paste(
            msg,
            sprintf(
                fmt = "       |   %.69s",
                which
            ),
            sep = "\n"
        )
    }
    message(msg)
    invisible(ok)
}



#' Program installation status
#' @note Updated 2020-04-09.
#' @noRd
installed <- function(
    which,
    required = TRUE,
    path = TRUE
) {
    stopifnot(
        requireNamespace("goalie", quietly = TRUE),
        goalie::isCharacter(which),
        goalie::isFlag(required),
        goalie::isFlag(path)
    )
    statusList <- status()
    invisible(vapply(
        X = which,
        FUN = function(which) {
            ok <- nzchar(Sys.which(which))
            if (!isTRUE(ok)) {
                if (isTRUE(required)) {
                    checkFail()
                    status <- statusList[["fail"]]
                } else {
                    status <- statusList[["note"]]
                }
                message(sprintf(
                    fmt = "  %s | %s missing.",
                    status, which
                ))
            } else {
                status <- statusList[["ok"]]
                msg <- sprintf("  %s | %s", status, which)
                if (isTRUE(path)) {
                    msg <- paste0(
                        msg, "\n",
                        sprintf("       |   %.69s", Sys.which(which))
                    )
                }
                message(msg)
            }
            invisible(ok)
        },
        FUN.VALUE = logical(1L)
    ))
}
