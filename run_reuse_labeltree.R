
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
image_metadata$type[image_metadata["strap_code"] >= 1000] <- "invertebre"

##
## Modifier le texte des labels
##

# ajouter le text "STRAP: " devant le code (ex devant le code "890" pour faire "STRAP: 890")
image_metadata$strap_code <- paste0("STRAP: ", image_metadata$strap_code)

# ajouter le text "no_station: " devant le numéro (ex devant "12" pour faire "no_station: 12")
image_metadata$set_number <- paste0("no_trait: ", image_metadata$set_number)

# ajouter le text "strat: " devant le numéro (ex devant "401" pour faire "strat: 401")
image_metadata$stratum_name <- paste0("strate: ", image_metadata$stratum_name)

# ajouter le text "strat: " devant le numéro (ex devant "401" pour faire "strat: 401")
image_metadata$nafo_name <- paste0("OPANO: ", image_metadata$nafo_name)

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
volume_id <- 213 # ex: 1234
biigle_images <- biigle_get_images(
    biigle_api_connection = biigle_api_connection,
    volume_id = volume_id
)
View(biigle_images)
# ajout le image_id de BIIGLE avec chaque image d'ANDES
# (les deux ont une colonne "filename")

# il faut parfois que les deux ai le meme format (avec ou sans "images/...")
biigle_images$filename <- paste0("images/", biigle_images$filename)

image_metadata <- merge(image_metadata, biigle_images, all.x = TRUE, all.y = FALSE)

##
## Label-tree BIIGLE avec les stations et noms scientifiques
##
source("r/biigle_get_labels.R")
# Label tree pour scientific_name
# Name: Taxons_IML
# Description: Liste taxonomique des taxons utilisé dans les divers projets de LIML dans le cadre de ses mandats au sein du MPO
# ID: 105
label_tree_id <- 105
scientific_name_labels <- biigle_get_labels(biigle_api_connection, label_tree_id)

# Label tree pour scientific_name
# Name : type
# Description: type: poisson vs invertebrés
# ID: 145
label_tree_id <- 145
type_labels <- biigle_get_labels(biigle_api_connection, label_tree_id)

# CODE POUR LA CREATION INITIALE DU LABEL-TREE STRATE/TRAIT/OPANO NE PAS EXECUTER!!!
# feature_data <- read.csv("strat_nGSL.csv", sep = ";")
# feature_data$Strate <- paste0("strate: ", feature_data$Strate)
# feature_data$OPANO <- paste0("OPANO: ", feature_data$OPANO)
# source("R/biigle_add_label.R")
# add_unique_column_values_as_labels(
#     biigle_api_connection,
#     feature_data,
#     label_tree_id,
#     column_name = "Strate"
# )
# add_unique_column_values_as_labels(
#     biigle_api_connection,
#     feature_data,
#     label_tree_id,
#     column_name = "OPANO"
# )
# traits <- data.frame(list("no_trait" = seq_len(300)))
# traits$no_trait <- paste0("no_trait: ", traits$no_trait)
# add_unique_column_values_as_labels(
#     biigle_api_connection,
#     traits,
#     label_tree_id,
#     column_name = "no_trait"
# )


# Label tree pour Strates
# Name : Zones
# Description: Noms de zones geographiques, strates et OPANO
# ID: 146
label_tree_id <- 147
strate_labels <- biigle_get_labels(biigle_api_connection, label_tree_id)

# Label tree pour OPANO
# Name : Zones
# Description: Noms de zones geographiques, strates et OPANO
# ID: 146
label_tree_id <- 147
opano_labels <- biigle_get_labels(biigle_api_connection, label_tree_id)

# Label tree pour no_traits
# Name : Zones
# Description: Noms de zones geographiques, strates et OPANO
# ID: 146
label_tree_id <- 147
no_trait_labels <- biigle_get_labels(biigle_api_connection, label_tree_id)


#
# Ajouter des colonnes ayant le label_id correspondant a chaque valeur dans image_metadata
# Pour chaque colonne d'intérêt, nous allons faire un left-merge pour ajouter une nouvelle colonne avec le label_id que nous venons d'obtenir.
# (e.g., pour "scientific_name" ajouter "scientific_name_label_id")
source("R/merge_label_id.R")

#
# merge on scientific_name to get scientific_name_label_id
image_metadata <- merge_label_id(
    image_metadata,
    biigle_labels = scientific_name_labels,
    column_name = "scientific_name"
)
write.csv(image_metadata[is.na(image_metadata$scientific_name_label_id),], "noms_scientifiques.csv")
write.csv(scientific_name_missing <- unique(image_metadata[is.na(image_metadata$scientific_name_label_id),"scientific_name"]), "noms_scientifiques_unique.csv") 


#
# merge on type to get type_label_id
image_metadata <- merge_label_id(
    image_metadata,
    biigle_labels = type_labels,
    column_name = "type"
)


#
# merge on stratum_name to get strate_label_id
image_metadata <- merge_label_id(
    image_metadata,
    biigle_labels = strate_labels,
    column_name = "stratum_name"
)


#
# merge on nafo_name to get strate_label_id
image_metadata <- merge_label_id(
    image_metadata,
    biigle_labels = opano_labels,
    column_name = "nafo_name"
)

#
# merge on set_number to get set_number_label_id
image_metadata <- merge_label_id(
    image_metadata,
    biigle_labels = no_trait_labels,
    column_name = "set_number"
)


View(image_metadata)

columns_that_are_labels <- c(
    "scientific_name",
    "type",
    "stratum_name",
    "nafo_name",
    "set_number"
)

#
# Associer les étiquettes au images
# Pour terminer, il suffit de boucler sur les lignes du dataframe pour associer les étiquettes (scientific_name_label_id et station_label_id) a chaque images.
source("R/biigle_label_image.R")
for (row in seq_len(nrow(image_metadata))) {

    image_id <- image_metadata[row, "image_id"]
    msg <- sprintf("Ajouts d'étiquettes pour image (id=%s) %d / %d ( %.2f percent )",
        image_id,
        row,
        nrow(image_metadata),
        row*1./nrow(image_metadata)
    )
    print(msg)

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
