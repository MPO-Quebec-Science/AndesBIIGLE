
library(httr)

#' Add a label to a BIIGLE label tree
#'
#' This makes a POST API call to api/v1/label-trees/:id/labels
#' https://biigle.de/doc/api/index.html#api-Label_Trees-StoreLabelTreesLabels
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param label_tree_id The label tree ID.
#' @param label_name The label string.
#' @param parent_label_id The id of the parent label.
#' @export
biigle_add_label <- function(biigle_api_connection, label_tree_id, label_name, parent_label_id = null) {
    chemin <- paste("/api/v1/label-trees/", label_tree_id, "/labels", sep = "")
    url_cible <- paste(biigle_api_connection$base_url, chemin, sep = "")

    etiquette <- list(
        name = label_name,
        color = "#FF0000"
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
    if (httr::status_code(reponse) != 200) {
        stop(sprintf("Erreur lors de l'ajout du label %s a la label tree %d",
            label_name,
            label_tree_id
        ))
    }
    # A successfull response contains the label id in a JSON
    # {
    #     "id": 4,
    #     "name": "Sea Cucumber",
    #     "parent_id": null,
    #     "label_tree_id": 1,
    #     "color": "bada55"
    # }

    resultat_txt <- httr::content(reponse, "text", encoding = "UTF-8")
    resultat_df <- jsonlite::fromJSON(resultat_txt, flatten = TRUE)
    return(resultat_df$id[0])
}


#' Adds a complete label branch to a BIIGLE label tree
#'
#' The Label branch comprises a parent node, and contains all unique values under column_name from image_metadata as child nodes.
#' This makes a POST API call to api/v1/label-trees/:id/labels
#' https://biigle.de/doc/api/index.html#api-Label_Trees-StoreLabelTreesLabels
#' 
#' Example, this is usefull to add all unique scientific names as labels under a parent node "scientific_name"
#' And will allow to tag images with their scientific names from this tree.
#' 
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param label_tree_id The label tree ID.
#' @param label_name The label string.
#' @param parent_label_id The id of the parent label.
#' @export
add_unique_column_values_as_labels <- function (biigle_api_connection, image_metadata, label_tree_id, column_name) {
    # boucle sur tous les valeurs uniques de la colonne
    vals <- unique(image_metadata[column_name])
    if (nrow(vals) == 0) {
        print(sprintf("Aucune valeur unique trouvée pour la colonne %s", column_name))
        return()
    }

    # add the parent label name as to start the branch
    parent_label_id <- biigle_add_label(
        biigle_api_connection = biigle_api_connection,
        label_tree_id = label_tree_id,
        label_name = column_name,
    )

    # now add all its children in the branch
    for (row in 0:nrow(vals)) {
        label_name <- vals[row, ]
        biigle_add_label(
            biigle_api_connection = biigle_api_connection,
            label_tree_id = label_tree_id,
            label_name = label_name,
            parent_label_id = parent_label_id
        )
    }
}
