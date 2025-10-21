
library(httr)

#' Add a label to a BIIGLE image
#'
#' This function associates a lable (referenced by label_id) to an image (referenced by image_id).
#' A POST request is made to api/v1/images/:id/labels
#' See https://biigle.de/doc/api/index.html#api-Images-StoreImageLabels
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param image_id The id of the image.
#' @param label_id The id of the label.
#' @export
biigle_label_image <- function(biigle_api_connection, image_id, label_id) {
    chemin <- paste("/api/v1/images/", image_id, "/labels", sep = "")
    url_cible <- paste(biigle_api_connection$base_url, chemin, sep = "")
    etiquette <- list(label_id = label_id)
    print(sprintf("Ajout de label_id=%s a image_id=%s", label_id, image_id))
    reponse <- httr::POST(
        url = url_cible,
        body = etiquette,
        encode = "json",
        biigle_api_connection$auth)
    # code_statut <- status_code(reponse)
    # TODO validate 200 response code
}