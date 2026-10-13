library(tidyverse)
library(igraph)
library(psych)
library(lme4)
library(bruceR)
library(ggplot2)

load("../../data/data_agg/SNmF_igraph.Rdata")
load("../../data/data_agg/post_final.Rdata")

if (!is.data.frame(post_final) || !identical(names(post_final)[1], "node_id")) {
  stop("post_final must be an anonymized data frame with node_id as its first column.")
}
if ("name" %in% names(post_final)) stop("post_final must not contain a name column.")
if (!is.list(SNmF_igraph) || length(SNmF_igraph) != n_net ||
    !all(vapply(SNmF_igraph, igraph::is_igraph, logical(1)))) {
  stop("SNmF_igraph must be a list of ", n_net, " igraph networks.")
}
if (nrow(post_final) != 113L) stop("post_final must contain 113 analysis participants.")
if (anyDuplicated(post_final$node_id)) stop("post_final contains duplicate node_id values.")
if (!all(vapply(SNmF_igraph, igraph::vcount, numeric(1)) == 127L)) {
  stop("Every network must contain 127 nodes.")
}

rownames(post_final) <- as.character(seq_len(nrow(post_final)))

# define network indices
# 1) by indicator: list(indegree = indegree_1..6, outdegree = ..., ...)
net_index_by_ind <- setNames(
  lapply(net_ind, \(x) paste0(x, "_", 1:n_net)),
  net_ind
)

# 2) by network: list(net1_index = c(indegree_1, outdegree_1, ...), ...)
net_index_by_net <- setNames(
  lapply(1:n_net, \(n) paste0(net_ind, "_", n)),
  paste0("net", 1:n_net)
)
net_index_all  <- unlist(net_index_by_ind, use.names = FALSE)

# scaling function
scale_ni <- function(df,
                     list_scale = NULL,
                     scaling = c("by_size", "z_score", "none"),
                     SNmF_igraph = NULL) {
  
  scaling <- match.arg(scaling)
  
  # ---------- basic checks ----------
  # if no list_scale is given, scale all the indices
  if (is.null(list_scale)) {
    list_scale <- grep("^(indegree|outdegree|betweenness|eigen)_", names(df), value = TRUE)
  }
  if (!all(list_scale %in% names(df))) stop("Some columns in 'list_scale' do not exist in df.")
  
  # ---------- none ----------
  if (scaling == "none") return(df)
  
  # ---------- z_score across the single sample ----------
  if (scaling == "z_score") {
    return(
      df %>%
        dplyr::mutate(dplyr::across(dplyr::all_of(list_scale),
                                    ~ as.numeric(scale(.x))))
    )
  }
  
  # ---------- by_size ----------
  if (is.null(SNmF_igraph)) stop("For scaling='by_size', you must provide SNmF_igraph.")
  
  g <- igraph::vcount(SNmF_igraph[[1]])
  df2 <- df
  
  has <- function(prefix) any(startsWith(list_scale, prefix))
  
  if (has("indegree")) {
    cols <- list_scale[startsWith(list_scale, "indegree")]
    df2 <- df2 %>% dplyr::mutate(dplyr::across(dplyr::all_of(cols), ~ .x / (g - 1)))
  }
  if (has("outdegree")) {
    cols <- list_scale[startsWith(list_scale, "outdegree")]
    df2 <- df2 %>% dplyr::mutate(dplyr::across(dplyr::all_of(cols), ~ .x / (g - 1)))
  }
  if (has("betweenness")) {
    cols <- list_scale[startsWith(list_scale, "betweenness")]
    df2 <- df2 %>% dplyr::mutate(dplyr::across(dplyr::all_of(cols), ~ .x * 2 / ((g - 1) * (g - 2))))
  }
  # eigen: do not scale
  
  df2
}

post_final <- scale_ni(post_final,
                       list_scale = net_index_all,
                       scaling = scaling,
                       SNmF_igraph = SNmF_igraph)

# factorize categorical variables
post_final <- post_final %>% mutate(gender = factor(gender))

all_behav <- c(bribery_behav, filler_behav)
