# ..............................................................................
# Script: Bayesian Belief Network Construction
# Project: FIBRAS2 - TNFD and Nature Positive Project
# Author: Edwin Uribe (Prioridades y escenarios)
# Date: 2026-08-05
# Description:
#   This script reads an Excel workbook that defines the structure of a Bayesian
#   Network (nodes and directed arcs) and contains Conditional Probability Tables
#   (CPTs) for each node with parents. It builds the network, fits it with the
#   provided distributions, visualizes the graph and probability bars, exports
#   the network to Netica format (.net), and provides a function for diagnostic inference
#   by querying the network with simulations.
# ..............................................................................


# Required libraries -----------------------------------------------------------
library(bnlearn)      # Bayesian network structure and fitting
library(gRain)        # Conversion to factor graph for inference
library(Rgraphviz)    # Graph visualization (required by bnlearn)
# Rgraphviz installation could be problematic, please see:
#https://bioconductor.posit.co/packages/3.20/bioc/html/Rgraphviz.html
# and follow the installation guide

library(openxlsx)     # Read Excel files
library(readxl)       # To get sheet names (excel_sheets)
library(crayon)

# ..............................................................................
# Main function ----------------------------------------------------------------
# Main function: build the Bayesian network from an Excel file


#' Builds a Bayesian network structure and its probability distributions
#' from a specifically formatted Excel workbook.
#'
#' The Excel file must contain the following sheets:
#'   - 'Nodos': list of node names.
#'   - 'Arcs': table with two columns ('from', 'to') defining directed arcs.
#'   - Additional sheets with prefix 'CPT_' followed by the child node name,
#'     containing the conditional probability table (CPT) for that node.
#'
#' @param excel.path Path to the .xlsx file.
#' @return A list with the following elements:
#'   - nodes: data.frame of nodes.
#'   - arcs: data.frame of arcs.
#'   - df.CPT_*: data.frames for each CPT.
#'   - Types: list with node type ("Conditional" or "Marginal").
#'   - dimnames: list of dimension names for CPT arrays.
#'   - dim: list of array dimensions.
#'   - Arrays: list of arrays with conditional probabilities.
#'   - Matrices: list of matrices for marginal nodes (uniform probability).
#'   - Dist: list of distributions (arrays or matrices) ready for custom.fit().
#' @export
bn.fibras <- function(excel.path, baseline.path) {
  
  # 1. Read nodes, arcs, and sheet names
  nodes <- read.xlsx(excel.path, sheet = 'Nodos')
  arcs  <- read.xlsx(excel.path, sheet = 'Arcs')
  cpts_list <- excel_sheets(excel.path)   # All sheets in the file
  baseline <- read.xlsx(baseline.path, sheet = '2020')
  
  # List to store all intermediate results
  result_list <- list()
  result_list[['nodes']] <- nodes
  result_list[['arcs']]  <- arcs
  
  # 2. Load all CPT sheets (starting from sheet 4, assuming fixed order)
  #    Note: the first sheets are assumed to be 'Nodos', 'Arcs', and possibly others.
  for (sheet in 4:length(cpts_list)) {
    sheet_name <- cpts_list[sheet]
    df <- read.xlsx(excel.path, sheet = sheet_name)
    result_list[[paste0('df.', sheet_name)]] <- df
  }
  
  # 3. Classify nodes as conditional (have parents) or marginal (no parents)
  nodes.list <- result_list[['nodes']]$Nodos
  arcs.df    <- result_list[['arcs']]
  type.list  <- list()
  
  # Structures to store distributions
  dimnames.list <- list()
  dim.list      <- list()
  arrays.list   <- list()
  matrix.list   <- list()
  dist.list     <- list()
  
  cat(blue('Number of nodes:', length(nodes.list), '\n'))
  
  for (i in seq_along(nodes.list)) {#seq_along(nodes.list)
    node.name <- nodes.list[i]
    cat('Processing node:', node.name, '\n')
    
    # 3.1. If the node appears in the 'to' column of arcs, it is conditional
    if (node.name %in% arcs.df$to) {
      cat('  -> Conditional\n')
      type.list[[node.name]] <- "Conditional"
      
      # Load the corresponding CPT (sheet assumed to be named 'CPT_node')
      cpt <- result_list[[paste0('df.CPT_', node.name)]]
      
      # Identify parent nodes: all columns except the first (child) and last (Freq)
      child.node <- names(cpt)[1]
      parental.names <- names(cpt)[c(-1, -ncol(cpt))]
      cat('    Parent nodes:', parental.names, '\n')
      
      # Ensure the child variable is a factor with unique levels
      cpt[, child.node] <- factor(cpt[, child.node], levels = unique(cpt[, child.node]))
      child.levels <- levels(cpt[, child.node])
      
      # Build dimensions and names for the probability array
      dimnames <- list()
      dimnames[[child.node]] <- child.levels
      dim <- list(length(child.levels))
      
      for (p in seq_along(parental.names)) {
        parent <- parental.names[p]
        parent.levels <- levels(factor(cpt[, parent], levels = unique(cpt[, parent])))
        dimnames[[parent]] <- parent.levels
        dim[[p + 1]] <- length(parent.levels)   # +1 because first dimension is the child
      }
      
      # Save dimension metadata
      dimnames.list[[paste0('dimnames_', node.name)]] <- dimnames
      dim.list[[paste0('dim_', node.name)]] <- dim
      
      # Create array with probabilities (from column 'Freq')
      prob_array <- array(unlist(cpt$Freq),
                          dim = unlist(dim),
                          dimnames = dimnames)
      arrays.list[[paste0('Array_', node.name)]] <- prob_array
      dist.list[[node.name]] <- prob_array
      
    } else {
      # 3.2. Node without parents → marginal (Base line data)
      cat('  -> Marginal\n')
      type.list[[node.name]] <- "Marginal"
      
      # Get node levels from the 'Nodos' sheet (column 'Categorias')
      levels_str <- nodes[nodes$Nodos == node.name, 'Categorias']
      ind_levels <- strsplit(levels_str, ' ')[[1]]
      n_levels <- length(ind_levels)
      
      # Uniform probability when base line do not exist
      if (node.name %in% c(baseline$Nodos)) {
        prob_vec <- baseline[baseline$Nodos == node.name,]$Probabilidad
      } else {
        prob_vec <- rep(1 / n_levels, n_levels)
        }
      prob_mat <- matrix(prob_vec, ncol = n_levels,
                         dimnames = list(NULL, ind_levels))
      
      matrix.list[[paste0('Matrix_', node.name)]] <- prob_mat
      dist.list[[node.name]] <- prob_mat
    }
  }
  
  # Store all structures in the output list
  result_list[['Types']]     <- type.list
  result_list[['dimnames']]  <- dimnames.list
  result_list[['dim']]       <- dim.list
  result_list[['Arrays']]    <- arrays.list
  result_list[['Matrices']]  <- matrix.list
  result_list[['Dist']]      <- dist.list
  
  return(result_list)
}

#...............................................................................
# Execution and network construction -------------------------------------------

# Excel principal con la estrutura de la red (Mirar codigo 1_CPT_Generation_FibrasII)
cat(blue('Cambiar la ruta del excel principal en la linea de abajo'))
# Path to the data file (adjust as needed)
excel.path <- "Pruebas/BN_FibrasIIv3.xlsx"

# Excel con la linea base a 2020 para los nodos marginales
cat(blue('Cambiar la ruta de la linea base en la linea de abajo'))
baseline.path <- "C:/Humboldt_2026/FIBRAS2/Linea_basePC/LineaBase_2020.xlsx"


# Build the network from Excel
web <- bn.fibras(excel.path, baseline.path)

# Get list of nodes
nodes <- web$nodes$Nodos

# Create empty DAG and add arcs
dag <- empty.graph(nodes)
arcs_matrix <- as.matrix(web$arcs)
arcs(dag) <- arcs_matrix

# Check that the graph is acyclic (should be TRUE)
cat(green('Is acyclic? ->', acyclic(dag), '\n'))

# Visualize the structure (optional)
plot(dag)

# Fit the network with the obtained distributions
bn_fitted <- custom.fit(dag, dist = web$Dist)

# Note: If an error occurs, it is usually due to incomplete CPTs.
#       Ensure all parent combinations are covered.

# ..............................................................................
# Visualization and export -----------------------------------------------------

# Save bar chart of probabilities (TIFF format)
cat(blue('Cambiar la ruta para exportar la imagen de la red en la linea de abajo'))
export.path.image1 <- "Sgraficas/BN_FibrasIIv22_08_2026.tiff"
tiff(export.path.image1,
     height = 120, width = 170, units = 'mm',
     compression = "lzw", res = 600)
graphviz.chart(bn_fitted, type = "barprob", grid = TRUE,
               bar.col = "darkred", strip.bg = "lightyellow")
dev.off()


# Export the network to .net format (compatible with Netica)
cat(blue('Cambiar la ruta para exportar la red en la linea de abajo'))
export.path <- 'C:/Humboldt_2026/FIBRAS2/Pruebas/pruebaR3_0.net'
write.net(export.path, bn_fitted)

# Convert to 'grain' object for gRain inference
bn_grain <- as.grain(bn_fitted)
plot(bn_grain$dag) # Optional

# Alternative DAG visualization with layout
graphviz.plot(dag,
              shape = "ellipse",
              layout = "dot",
              main = "Bayesian Network Structure")

# ..............................................................................
# Manual diagnostic ------------------------------------------------------------
# Inference by simulation


#' Performs inference on physical risk given evidence on three variables (Dummy example).
#'
#' @param Inundaciones_v   Flood level (must match node levels or categories).
#' @param Quemas_incendios_v Burn/fire level.
#' @param Calidad_habitat_v  Habitat quality level.
#' @return Estimated probability that "Riesgos_fisicos" is "Aumento".
diagnose_manual <- function(Inundaciones_v, Quemas_incendios_v, Calidad_habitat_v) {
  
  # Estimate via likelihood weighting sampling
  prob <- cpquery(bn_fitted,
                  event = (Riesgos_fisicos == "Aumento"),
                  evidence = list(Inundaciones = Inundaciones_v,
                                  Quemas_incendios = Quemas_incendios_v,
                                  Calidad_habitat = Calidad_habitat_v),
                  method = "lw")
  
  # Show results in console
  cat("Scenario profile:\n")
  cat("- Floods:", Inundaciones_v, "\n")
  cat("- Burns/fires:", Quemas_incendios_v, "\n")
  cat("- Habitat quality:", Calidad_habitat_v, "\n")
  cat("\nProbability of increased Physical Risks:", round(prob * 100, 1), "%\n")
  
  # Qualitative interpretation
  if (prob > 0.6) {
    cat(red("High probability of increase.\n"))
  } else {
    cat(red("Low probability of increase.\n"))
  }
  
  return(prob)
}

# Example usage
cat(blue('Ejemplo de dianostico\n'))
diagnose_manual("Atipico", "Incremento", "Aumento")

cat(green('Processing finished.\n'))
