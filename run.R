##
## connexion a la BD
##
andes_url_bd <- "iml-science-4.ent.dfo-mpo.ca"
andes_port_bd <- 25985 #IML-2025-015 Relevé Écosystemique
andes_nom_bd <- "andesdb"
andes_nom_usager_bd <- Sys.getenv("ANDES_NOM_USAGER_BD")
andes_mot_de_passe_bd <- Sys.getenv("ANDES_MOT_DE_PASSE_BD")

# établir connexion BD (il faut être sur le réseau MPO)
source("R/andes_db_connect.R")
andes_db_connection <- andes_db_connect(
    url_bd = andes_url_bd,
    port_bd = andes_port_bd,
    nom_bd = andes_nom_bd,
    nom_usager = andes_nom_usager_bd,
    mot_de_passe = andes_mot_de_passe_bd
)

##
## Table ANDES en dataframe
##
source("R/get_image_metadata.R")
image_metadata <- get_image_metadata(andes_db_connection)
View(image_metadata)


##
## Connexion et authentification BIIGLE
##
source("R/biigle_api_connect.R")
biigle_base_url <- "http://biigle.ent.dfo-mpo.ca"
biigle_email <- Sys.getenv("BIIGLE_EMAIL")
biigle_token <- Sys.getenv("BIIGLE_TOKEN")
# biigle_email <- "BLABLABLA@dfo-mpo.gc.ca"
# biigle_token <- "MON_JETON_TOP_SECRET"

biigle_api_connection <- biigle_api_connect(
    base_url = biigle_base_url,
    email = biigle_email,
    token = biigle_token
)


##
## Obtention des images BIIGLE du volume
##
source("R/get_biigle_images.R")
volume_id <- 148 # ex: 1234
biigle_images <- get_biigle_images(
    biigle_api_connection = biigle_api_connection,
    volume_id = volume_id
)
View(biigle_images)



##
## Faire un Label-tree avec les stations et noms scientifiques
##

# manuellement faire le label tree et les deux parents :Þ
label_tree_id <- 1234567
# scientific_name_label_id <- 2345678
# station_name_label_id <- 23456789
# strap_code_label_id <- 23456789
# aphia_id_code_label_id <- 23456789
# poisson_invertbre_label_id <- 23456789

# # boucle sur tous les noms_scientifiques uniques qui apparaissent dans les metadonées d'images
# noms_scientifique <- unique(image_metadata["scientific_name"])
# for (row in 0:nrow(noms_scientifique)) {
#     espece <- noms_scientifique[row, ]
#     biigle_add_label(
#         biigle_api_connection = biigle_api_connection,
#         label_tree_id = label_tree_id,
#         label_name = espece,
#         parent_label_id = scientific_name_label_id
#     )
# }

# # boucle sur tous les aphias_ids uniques qui apparaissent dans les metadonées d'images
# aphia_ids <- unique(image_metadata["aphia_id"])
# for (row in 0:nrow(aphia_ids)) {
#     label_name <- aphia_ids[row, ]
#     biigle_add_label(
#         biigle_api_connection = biigle_api_connection,
#         label_tree_id = label_tree_id,
#         label_name = label_name,
#         parent_label_id = aphia_id_code_label_id
#     )
# }

# # boucle sur tous les code_straps uniques qui apparaissent dans les metadonées d'images
# aphia_ids <- unique(image_metadata["aphia_id"])
# for (row in 0:nrow(aphia_ids)) {
#     label_name <- aphia_ids[row, ]
#     biigle_add_label(
#         biigle_api_connection = biigle_api_connection,
#         label_tree_id = label_tree_id,
#         label_name = label_name,
#         parent_label_id = aphia_id_code_label_id
#     )
# }


# # boucle sur tous les noms_stations uniques qui apparaissent dans les metadonées d'images
# noms_stations <- unique(image_metadata["station_name"])
# for (row in 0:nrow(noms_stations)) {
#     station <- noms_stations[row, ]
#     biigle_add_label(
#         biigle_api_connection = biigle_api_connection,
#         label_tree_id = label_tree_id,
#         label_name = station,
#         parent_label_id = station_name_label_id
#     )
# }


#
# au lieu de refaire le meme code
#
source("R/add_unique_column_values_as_labels.R")

# add all the unique scientific names
add_unique_column_values_as_labels(
    biigle_api_connection = biigle_api_connection,
    image_metadata = image_metadata,
    label_tree_id = label_tree_id,
    column_name = "scientific_name")

# add all the unique station names
add_unique_column_values_as_labels(
    biigle_api_connection = biigle_api_connection,
    image_metadata = image_metadata,
    label_tree_id = label_tree_id,
    column_name = "station_name")


# add all the unique set_numbers
add_unique_column_values_as_labels(
    biigle_api_connection = biigle_api_connection,
    image_metadata = image_metadata,
    label_tree_id = label_tree_id,
    column_name = "set_number")


# add all the unique strap codes
add_unique_column_values_as_labels(
    biigle_api_connection = biigle_api_connection,
    image_metadata = image_metadata,
    label_tree_id = label_tree_id,
    column_name = "strap_code")

#
# Obtenir les labels_ids de chaque étiquette
# maintenant le label-tree est construit et complet dans BIIGLE, nous pouvons l'obtenir pour voir les ID de chaque étiquettes
etiquettes  <- biigle_get_labels(
    biigle_api_connection = biigle_api_connection,
    label_tree_id = label_tree_id
)

#
# Ajouter des colonnes ayant le label_id correspondant a chaque valeur dans image_metadata
# Pour chaque colonne d'intérêt, nous allons faire un left-merge pour ajouter une nouvelle colonne avec le label_id que nous venons d'obtenir.
# (e.g., pour "scientific_name" ajouter "scientific_name_label_id")
source("R/merge_label_id.R")

# merge on scientific_name to get scientific_name_label_id
image_metadata <- merge_label_id(image_metadata,
    biigle_labels = etiquettes,
    column_name = "scientific_name"
)

# merge on station_name to get station_name_label_id
image_metadata <- merge_label_id(image_metadata,
    biigle_labels = etiquettes,
    column_name = "station_name"
)

# merge on set_number to get set_number_label_id
image_metadata <- merge_label_id(image_metadata,
    biigle_labels = etiquettes,
    column_name = "set_number"
)

# merge on strap_code to get strap_code_label_id
image_metadata <- merge_label_id(image_metadata,
    biigle_labels = etiquettes,
    column_name = "strap_code"
)


#
# Associer les étiquettes au images
# Pour terminer, il suffit de boucler sur les lignes du dataframe pour associer les étiquettes (scientific_name_label_id et station_label_id) a chaque images.
for (row in seq_len(nrow(image_metadata))) {
    image_id <- df[row, "image_id"]

    # ajouter le label scientific name (scientific_name_label_id)
    label_id <- df[row, "scientific_name_label_id"]
    biigle_label_image(
        biigle_api_connection = biigle_api_connection,
        image_id = image_id,
        label_id = label_id
    )

    # ajouter le label de station (station_label_id)
    label_id <- df[row, "station_name_label_id"]
    biigle_label_image(
        biigle_api_connection = biigle_api_connection,
        image_id = image_id,
        label_id = label_id
    )

    # ajouter le label de set_number (set_number_label_id)
    label_id <- df[row, "set_number_label_id"]
    biigle_label_image(
        biigle_api_connection = biigle_api_connection,
        image_id = image_id,
        label_id = label_id
    )

    # ajouter le label de strap_code (strap_code_label_id)
    label_id <- df[row, "strap_code_label_id"]
    biigle_label_image(
        biigle_api_connection = biigle_api_connection,
        image_id = image_id,
        label_id = label_id
    )

}