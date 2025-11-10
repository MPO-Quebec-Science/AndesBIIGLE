
##
## connexion a la BD ANDES
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
## Ajouter la colonne type (avec valeur 'poisson' ou 'invertebres') selon code_strap
##
image_metadata$type[image_metadata["strap_code"] < 1000] <- "poisson"
image_metadata$type[image_metadata["strap_code"] >= 1000] <- "invertebres"


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
source("R/biigle_get_images.R")
volume_id <- INSERT_HERE # ex: 1234
biigle_images <- biigle_get_images(
    biigle_api_connection = biigle_api_connection,
    volume_id = volume_id
)

# il faut parfois que les deux ai le meme format (avec ou sans "images/...")
biigle_images$filename <- paste0("images/", biigle_images$filename)

View(biigle_images)
# ajout le image_id de BIIGLE avec chaque image d'ANDES
# (les deux ont une colonne "filename")
image_metadata <- merge(image_metadata, biigle_images, all.x = TRUE, all.y = FALSE)


##
## Faire un Label-tree BIIGLE avec les stations et noms scientifiques
##


# manuellement faire le label tree pour la mission, et mettre le ID ici
label_tree_id <- INSERT_HERE
source("R/biigle_add_label.R")

# ces colonns vont devenir une branch de labels
columns_that_are_labels <- c(
    "scientific_name",
    "station_name",
    "set_number",
    "strap_code",
    "type",
    "aphia_id"
)

for (column_name in columns_that_are_labels) {
    print(sprintf("Ajout des étiquettes pour la colonne %s", column_name))
    add_unique_column_values_as_labels_bulk(
        biigle_api_connection = biigle_api_connection,
        image_metadata = image_metadata,
        label_tree_id = label_tree_id,
        column_name = column_name)
}


#
# Obtenir les labels_ids de chaque étiquette
# maintenant que le label-tree est construit et complet dans BIIGLE, nous voulons l'obtenir afin d'avoir les ID de chaque étiquettes
source("R/biigle_get_labels.R")
etiquettes  <- biigle_get_labels(
    biigle_api_connection = biigle_api_connection,
    label_tree_id = label_tree_id
)


#
# Ajouter des colonnes ayant le label_id correspondant a chaque valeur dans image_metadata
# Pour chaque colonne d'intérêt, nous allons faire un left-merge pour ajouter une nouvelle colonne avec le label_id que nous venons d'obtenir.
# (e.g., pour "scientific_name" ajouter "scientific_name_label_id")
source("R/merge_label_id.R")
for (column_name in columns_that_are_labels) {
    print(sprintf("Ajouter le label ID opur la colonne %s", column_name))
    # merge on scientific_name to get scientific_name_label_id
    image_metadata <- merge_label_id(
        image_metadata,
        biigle_labels = etiquettes,
        column_name = column_name
    )
}
#
# Associer les étiquettes au images
# Pour terminer, il suffit de boucler sur les lignes du dataframe pour associer les étiquettes (scientific_name_label_id et station_label_id) a chaque images.
source("R/biigle_label_image.R")
for (row in seq_len(nrow(image_metadata))) {
    image_id <- image_metadata[row, "image_id"]
    print(sprintf("Ajouts d'étiquettes pour image (id=%s) %d / %d ( %.2f percent )",
        image_id,
        row,
        nrow(image_metadata),
        row*100./nrow(image_metadata)
    ))

    for (column_name in columns_that_are_labels) {
        label <- image_metadata[row, column_name]
        label_id <- image_metadata[row, paste(column_name, "_label_id", sep = "")]
        print(sprintf("    Ajouter le label %s (label_id=%s) de la colonne %s", label, label_id, column_name))
        # ajouter le label a l'image

        biigle_label_image(
            biigle_api_connection = biigle_api_connection,
            image_id = image_id,
            label_id = label_id
        )
    }
}
