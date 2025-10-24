
library(httr)
library(jsonlite)

#' Gets image metadata as dataframe from a database query to ANDES
#'
#' This function executes a REST-API call to a BIIGLE instance to retrieve the images a volume.
#' A GET request is made to the path api/v1/volumes/:id/filenames
#' See https://biigle.de/doc/api/index.html#api-Volumes-VolumeIndexFilenames
#'
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param volume_id The BIIGLE volume id to get images from.
#' @return A dataframe containing the images in the volume
#' @export
biigle_get_images <- function(biigle_api_connection, volume_id) {

    api_path <- paste("/api/v1/volumes/", volume_id, "/filenames", sep = "")
    url_cible <- paste(biigle_api_connection$base_url, api_path, sep = "")

    reponse <- httr::GET(url = url_cible, accept_json(), biigle_api_connection$auth)

    code_statut <- httr::status_code(reponse)
    if (code_statut != 200 | code_statut != 201) {
        sprintf("Erreur lors de le l'obention des images (code=%d)", code_statut)
        print(content(reponse, "text"))
        return()
    }

    resultat_txt <- httr::content(reponse, "text", encoding = "UTF-8")
    resultat_list <- jsonlite::fromJSON(resultat_txt, flatten = TRUE)
    # un peu de jonglerie :)
    resultat_list <- list(
        filename = unlist(unname(resultat_list)),
        image_id = names(resultat_list)
    )
    resultat_df <- data.frame(resultat_list)
    return(resultat_df)
}
