
library(httr)

#' Add a single label to a BIIGLE label tree
#'
#' This makes a POST API call to api/v1/label-trees/:id/labels
#' https://biigle.de/doc/api/index.html#api-Label_Trees-StoreLabelTreesLabels
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param label_tree_id The label tree ID.
#' @param label_name The label string.
#' @param parent_label_id The id of the parent label.
#' @param color The color code for the labels, default is red "#FF0000"
#' @export
biigle_add_label <- function(biigle_api_connection, label_tree_id, label_name, parent_label_id = NULL,  color = "#FF0000") {
    chemin <- paste("/api/v1/label-trees/", label_tree_id, "/labels", sep = "")
    url_cible <- paste(biigle_api_connection$base_url, chemin, sep = "")

    if (is.null(parent_label_id)) {
        etiquette <- list(
        name = label_name,
        color = "#FF0000"
        )
        print(sprintf("Ajout de %s a la list %d ",
            label_name,
            label_tree_id
        ))

    } else {
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
    }

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
    return(resultat_df$id)
}


#' Add a multiple labels to a BIIGLE label tree
#'
#' This makes a POST API call to api/v1/label-trees/:id/merge-labels
#' https://biigle.de/doc/api/index.html#api-Label_Trees-StoreLabelTreesMergeLabels
#' 
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param label_tree_id The label tree ID.
#' @param parent_label_name The label string of the new parent label.
#' @param label_list  List of label strings to add as children of parent_label. Please make sure to omit the NA values from this list.
#' @param color The color code for the labels, default is red "#FF0000"
#' @export
biigle_add_bulk_labels <- function(biigle_api_connection, label_tree_id, parent_label_name, label_list, color = "#FF0000") {
    chemin <- paste("/api/v1/label-trees/", label_tree_id, "/merge-labels", sep = "")
    url_cible <- paste(biigle_api_connection$base_url, chemin, sep = "")
    # Need to prepare a payload that has this structure...
    # {
    # "create": [
    #    {
    #      "name": "My new parent",
    #      "color": "bada55"
    #      "children": [
    #         {
    #            "name": "My new child",
    #            "color": "c0ffee"
    #         }
    #      ]
    #   },
    # "remove": []
    #}

    children <- data.frame(list(
        name = label_list,
        color = color
    ))
    parent <- list(
        name = parent_label_name,
        color = color,
        children = children
    )
   
    payload <- list(
        create = list(parent),
        remove = list()
    )

    # test the JSON payload
    jsonlite::toJSON(payload, auto_unbox = TRUE, pretty = TRUE)

    reponse <- httr::POST(
        url = url_cible,
        body = payload,
        encode = "json",
        auto_unbox = TRUE,
        pretty = TRUE,
        biigle_api_connection$auth)

    # validate 200 response code
    code_statut <- httr::status_code(reponse)
    if (code_statut != 200 | code_statut != 201) {
        sprintf("Erreur lors de l'ajout en vrac de labels (code=%d)", code_statut)
        # print(content(reponse, "text"))
        sprintf("Erreur lors de l'ajout en vrac de labels au label-tree %d", label_tree_id)
        stop()
    }

    return()
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
#' @param image_metadata The the dataframe having the labels under a columns
#' @param label_tree_id The label tree id.
#' @param column_name The name of the column in image_metadata that contains the labels to add.
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
    for (row in 1:nrow(vals)) {
        label_name <- vals[row, ]

        # skip if the label is NA or empty 
        if (is.na(label_name) || label_name == "") {
            next
        }
        biigle_add_label(
            biigle_api_connection = biigle_api_connection,
            label_tree_id = label_tree_id,
            label_name = label_name,
            parent_label_id = parent_label_id
        )
    }
}

#' Adds a complete label branch to a BIIGLE label tree. The bulk version addes the children as a single API call
#'
#' The Label branch comprises a parent node, and contains all unique values under column_name from image_metadata as child nodes.
#' This makes a POST API call to api/v1/label-trees/:id/labels
#' https://biigle.de/doc/api/index.html#api-Label_Trees-StoreLabelTreesLabels
#' 
#' Example, this is usefull to add all unique scientific names as labels under a parent node "scientific_name"
#' And will allow to tag images with their scientific names from this tree.
#' 
#' @param biigle_api_connection An api connection helper object. Use biigle_api_connect() to create one.
#' @param image_metadata The the dataframe having the labels under a columns
#' @param label_tree_id The label tree id.
#' @param column_name The name of the column in image_metadata that contains the labels to add.
#' @export
add_unique_column_values_as_labels_bulk <- function (biigle_api_connection, image_metadata, label_tree_id, column_name) {
    # boucle sur tous les valeurs uniques de la colonne
    label_list <- unique(image_metadata[column_name])
    # retirer les NA
    label_list <- na.omit(label_list)
    # a single list of names
    label_list <- list(name = label_list[, 1])
    if (length(label_list) == 0) {
        print(sprintf("Aucune valeur unique trouvée pour la colonne %s", column_name))
        return()
    }

    biigle_add_bulk_labels(biigle_api_connection, label_tree_id, parent_label=column_name, label_list)

}
