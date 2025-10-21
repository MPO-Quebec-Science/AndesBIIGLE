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

