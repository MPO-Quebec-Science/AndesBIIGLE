
library(httr)

#' Generate an object containing authenfication header to use the BIIGLE REST-API
#'
#' This function builds a helper object containing all needed information to make REST-API calls.
#' It is needed to create every request.
#'
#'
#' @param base_url The base url for the BIIGLE instance.
#' @param email The BIIGLE user email.
#' @param token The BIIGLE user API token.
#' @return A biigle_api_connection object needed to make subsequent API calls.
#' @export
biigle_api_connect <- function(base_url, email, token) {
    auth <- httr::authenticate(email, token, type = "basic")
    biigle_api_connection <- list(
        base_url = base_url,
        auth = auth
    )
    return(biigle_api_connection)
}
