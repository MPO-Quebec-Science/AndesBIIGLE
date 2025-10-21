
library(httr)

#' Add a label to a BIIGLE label tree
#'
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param label_tree_id The label tree ID.
#' @param label_name The label string.
#' @param parent_label_id The id of the parent label.
#' @export
biigle_add_label <- function(biigle_api_connection, label_tree_id, label_name, parent_label_id) {
    # https://biigle.de/doc/api/index.html#api-Label_Trees-StoreLabelTreesLabels
    # POST api/v1/label-trees/:id/labels
    chemin <- paste("/api/v1/label-trees/", label_tree_id, "/labels", sep = "")
    url_cible <- paste(biigle_api_connection$base_url, chemin, sep = "")

    etiquette <- list(
        name = label_name,
        color = "#FF0000",
        parent_id = parent_label_id
    )

    print(sprintf("Ajout de %s a la list %d (parent=%d) ",
        label_name,
        label_tree_id,
        parent_label_id
    ))

    reponse <- httr::POST(
        url = url_cible,
        body = etiquette,
        encode = "json",
        biigle_api_connection$auth)

    # TODO validate 200 response code
}