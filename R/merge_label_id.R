

merge_label_id <- function(image_metadata, biigle_labels, column_name) {
    # rename the generic "name" column to have the target column_name
    names(biigle_labels)[names(biigle_labels) == "name"] <- column_name

    # rename the generic label_id column to be prepended with "column_name"
    names(biigle_labels)[names(biigle_labels) == "label_id"] <- paste(column_name, "_label_id", sep="")

    # perform the left-merge to assign the label_ids
    temp <- (merge(image_metadata, biigle_labels, all.x = TRUE, all.y = FALSE))

    # return the datafram with the new column having the label ids
    return(temp)
}
