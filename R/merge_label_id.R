#' Merge a label_id column
#'
#' This function associates a label (referenced by a label_id) to an image (referenced by image_id).
#' The a merge between two dataframes will be made using 
#' A POST request is made to api/v1/images/:id/labels
#' See https://biigle.de/doc/api/index.html#api-Images-StoreImageLabels
#' @param image_metadata a dataframe containing a `column_name` (and normally an "image_id") column 
#' @param biigle_labels a dataframe containing the "name" and "label_id" column  
#' @param column_name The name that the columns containing the labels, a new column having "_label_id" appended to the `column_name` will be created.
#' @export
merge_label_id <- function(image_metadata, biigle_labels, column_name) {

    # make sure column_name is in image_metadata
    if (!(column_name %in% names(image_metadata))) {
        msg <- sprintf("Column column_name=%s is not in image_metadata.", column_name)
        stop(msg)
    }

    if (!("name" %in% names(biigle_labels)) || !("label_id" %in% names(biigle_labels))) {
        msg <- sprintf("Column name or label_id is not in biigle_labels. These two columns must be present.")
        stop(msg)
    }

    # rename the generic "name" column to have the target column_name
    names(biigle_labels)[names(biigle_labels) == "name"] <- column_name

    # rename the generic label_id column to be prepended with "column_name"
    names(biigle_labels)[names(biigle_labels) == "label_id"] <- paste(column_name, "_label_id", sep="")

    # perform the left-merge to assign the label_ids
    temp <- (merge(image_metadata, biigle_labels, all.x = TRUE, all.y = FALSE, by = column_name ))

    # return the datafram with the new column having the label ids
    return(temp)
}
