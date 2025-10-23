library(httr)
library(jsonlite)

#' Gets labels from a BIIGLE label tree
#'
#' This function executes a REST-API call to a BIIGLE instance to retrieve the labels in a labeltree.
#' A GET request is made to the path api/v1/label-trees/:id
#' See https://biigle.de/doc/api/index.html#api-Label_Trees-ShowLabelTrees
#'
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param label_tree_id The BIIGLE label_tree id to get the labels from.
#' @return A dataframe containing the labels in the label tree. (with ID and text)
#' @export
biigle_get_labels <- function(biigle_api_connection, label_tree_id) {
    # https://biigle.de/doc/api/index.html#api-Label_Trees-ShowLabelTrees
    # GET api/v1/label-trees/:id
    chemin <- paste("/api/v1/label-trees/", label_tree_id, sep = "")
    url_cible <- paste(biigle_api_connection$base_url, chemin, sep = "")

    reponse <- httr::GET(url = url_cible,
        accept_json(),
        biigle_api_connection$auth
    )

    code_statut <- status_code(reponse)
    if (code_statut != 200 | code_statut != 201) {
        sprintf("Erreur lors de le l'obention des labels (code=%d)", code_statut)
        print(content(reponse, "text"))
        return()
    }

    resultat_txt <- httr::content(reponse, "text", encoding = "UTF-8")
    resultat_df <- jsonlite::fromJSON(resultat_txt, flatten = TRUE)

    resultat_df <- resultat_df$labels

    # only keep two columns: id and name
    resultat_df <- resultat_df[,
        colnames(resultat_df) == "id" |
        colnames(resultat_df) == "name"
    ]

    # rename id column to label_id
    names(resultat_df)[names(resultat_df) == "id"] <- "label_id"

    return(resultat_df)
}
