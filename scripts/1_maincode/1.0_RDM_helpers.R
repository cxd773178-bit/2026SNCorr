my_RDM <- function(df_input, input_label, which_dist = "euclidean") {
  
  # colname_tmp <- paste0("dist_",which_dist,"_",input_label)
  
  if (which_dist == "correlation") {
    
    df_input.t <- as.data.frame(t(df_input)) 
    df_dist <- 1 - cor(df_input.t)
    
  } else {
    
    df_dist <- df_input %>%
      dist(method = which_dist) %>%
      as.matrix()
    
  }
  
  # Convert to long format without cor_gather() to avoid automatic "X" prefixes.
  df_RDM <- df_dist %>%
    as.data.frame(optional = TRUE) %>%
    tibble::rownames_to_column("var1") %>%
    tidyr::pivot_longer(-var1, names_to = "var2", values_to = "dist") %>%
    mutate(
      var1 = as.numeric(stringr::str_remove_all(var1, "[^0-9]")),
      var2 = as.numeric(stringr::str_remove_all(var2, "[^0-9]")),
      dist = as.numeric(dist)
    )
  
  return(df_RDM)
}
