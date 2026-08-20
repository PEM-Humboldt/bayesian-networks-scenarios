# ..............................................................................
# Script: Bayesian Network CPT Generation from Expert Criteria
# Project: FIBRAS2 - TNFD and Nature Positive Project
# Author: Edwin Uribe (Priridades y escenarios)
# Date: 2026-08-04
# Description:

#   This script reads an Excel workbook containing node definitions, arc
#   structure, and conditional probability data (from expert workshops).
#   For each node that has parents, it builds a
#   complete Conditional Probability Table (CPT) by combining the marginal
#   probabilities of the node given each parent.
#   The generated CPTs are written back into the same Excel file as new
#   worksheets named "CPT_<node>".
# ..............................................................................

# Load required libraries 
library(dplyr)        # Data manipulation
library(tidyr)        # Data tidying
library(openxlsx)     # Read/write Excel files
library(crayon)       # Message color manipulation 
# ..............................................................................
# 1. Environment setup ---------------------------------------------------------

# Set working directory to the project root (adjust as needed)
cat(blue('Configurar ambiente de trabajo en la linea de abajo\n'))
setwd('C:/Humboldt_2026/FIBRAS2')

# ..............................................................................
# 2. Input data ----------------------------------------------------------------


# The workbook contains four sheets:
#   - "Nodos"   : Node definitions (name, role, categories, etc.)
#   - "Arcs"    : Directed edges (From -> To) defining the network structure
#   - "Probs"   : Conditional probability data from expert elicitation
#                 (contains scores for each combination of child, predictor,
#                  method, and state values)
cat(blue('Configurar la ruta de insumos en la linea de abajo\n'))
main.excel.path <- "Pruebas/BN_FibrasIIv3.xlsx"
nodes <- read.xlsx(main.excel.path, sheet = 'Nodos')
arcs  <- read.xlsx(main.excel.path, sheet = 'Arcs')
probs <- read.xlsx(main.excel.path, sheet = 'Probs')

# ..............................................................................
#3. probability data function --------------------------------------------------

# Helper function to extract probability data for a specific child node,
# predictor, and method (Calibrado/Inferido).

# This function filters the 'probs' data frame based on the given criteria
# and returns a list containing:
#   - score      : numeric probability (ceiling of the stored value)
#   - estado.p   : state of the predictor (parent node) for the target combination
#   - estado.r   : state of the response (child node) for the target combination
#   - estado.int.p : intermediate state of predictor (if any)
#   - estado.int.r : intermediate state of response (if any)
get_prob_data <- function(probs, child.node, predictor, metodo) {
  subset <- probs[probs$Variable.Respuesta == child.node & 
                    probs$Predictor == predictor & 
                    probs$Metodo == metodo, ]
  
  list(
    score = ceiling(as.numeric(subset$Probabilidad)),   # Ensure integer score
    estado.p = subset$Estado.objetivo.predictor,
    estado.r = subset$Estado.objetivo.Respuesta,
    estado.int.p = subset$Estado.Intermedio.p,
    estado.int.r = subset$Estado.Intermedio.r
  )
}

# ..............................................................................
# 4 Main loop ------------------------------------------------------------------
# Iterate over all nodes to generate CPTs for non-marginal nodes

# For each node in the network, determine its role and generate a CPT
# if it has parents (i.e., is a conditional node).
# Marginal nodes do not require a CPT.

for (r in 1:nrow(nodes)) {
  
  # 4.1 Categorize nodes by role for reference (though not all roles are used)
  lista.impactos.ext <- nodes[nodes$Rol == 'Impactos externos',]$Nodos
  lista.impactos.eco <- nodes[nodes$Rol == 'Impactos ecopetrol',]$Nodos
  lista.impactos.dep <- nodes[nodes$Rol == 'Dependencias',]$Nodos
  lista.impactos.ind <- nodes[nodes$Rol == 'Indicador',]$Nodos
  # Combine all impact categories into one list (not strictly needed for CPT)
  lista.impactos <- c(lista.impactos.ext, lista.impactos.eco,
                      lista.impactos.dep, lista.impactos.ind)
  
  # Clear the grid list for this iteration (used to build the Cartesian product)
  grid.l <- list()
  print(paste("Processing node index:", r))
  
  # 4.2 Skip marginal nodes (no parents) – they do not need CPT
  if (nodes$Rol[r] == 'Impactos externos' | nodes$Rol[r] == 'Oportunidades') {
    print('Marginal node – no CPT required')
    next   # Skip to next node
  }
  
  # 4.3 For conditional nodes (have at least one parent), generate CPT
  if (nodes$Rol[r] == 'Impactos ecopetrol' | 
      nodes$Rol[r] == 'Dependencias'  |
      nodes$Rol[r] == 'Indicador' |
      nodes$Rol[r] == 'Riesgos') {
    
    # Identify the parents of the current child node from the arcs data
    parent.nodes <- arcs[arcs$to == nodes$Nodos[r], ]$From
    child.node <- nodes$Nodos[r]
    print(paste0('Conditional node (child): ', child.node))
    
    # Retrieve the states (categories) for the child node
    # Categories are stored as space-separated strings, e.g., "Low Medium High"
    estados <- strsplit(nodes$Categorias[r], " ")[[1]]
    
    # 4.4 Build a list of state vectors for the child and all its parents.
    #     This list will be used to create all possible combinations
    #     that form the rows of the CPT.
    grid.hijo <- list()            # States of the child
    grid.padres <- list()          # States of each parent (named by parent node)
    
    for (p in 1:length(parent.nodes)) {
      # Extract the state categories for each parent node from the nodes table
      estados.parent <- strsplit(nodes[nodes$Nodos == parent.nodes[p], ]$Categorias, ' ')[[1]]
      # Store in the list with the parent node name as key
      grid.padres[parent.nodes[p]] <- list(estados.parent)
    }
    
    # Combine child states and parent states into a single list for expand.grid
    grid.l[[child.node]] <- list('estados' = estados, estados.parentales = grid.padres)
    grid.hijo[child.node] <- list(estados)
    
    # Create all combinations of child states and parent states
    params <- c(grid.hijo, grid.padres)   # List of all state vectors
    cpt.table <- do.call(expand.grid, params)
    # Note: expand.grid orders columns alphabetically, but order is not critical
    #       as we will later fill in probability values by column names.
    
    # 4.5 Write the initial (empty) CPT table to a temporary worksheet in the Excel file
    wb <- loadWorkbook(main.excel.path)
    # Remove any existing CPT sheet for this node to avoid duplicates
    if (paste0("CPT_", child.node) %in% names(wb)) {
      removeWorksheet(wb, paste0("CPT_", child.node))
    }
    addWorksheet(wb, paste0("CPT_", child.node))
    writeData(wb, paste0("CPT_", child.node), cpt.table)
    saveWorkbook(wb, "main.excel.path", overwrite = TRUE)
    
    # 4.6 Estimate the conditional probabilities for each combination
    #     For each parent (predictor), we derive a score from the 'probs' data
    #     for both "Calibrado" and "Inferido" methods, then combine them.
    vars <- ncol(cpt.table)   # Number of state columns (child + parents)
    
    # Iterate over each parent column (skip the first column, which is the child)
    for (c in 2:ncol(cpt.table)) {
      predictor <- colnames(cpt.table)[c]
      # Create a new column to store the score for this predictor
      new_name <- paste0("Score_", colnames(cpt.table)[c])
      cpt.table[[new_name]] <- NA
      
      # --- Calibrado (calibrated) probability ---
      cal <- get_prob_data(probs, child.node, predictor, "Calibrado")
      # Find rows where the parent state equals the calibrated parent state
      # AND the child state equals the calibrated response state
      idx <- cpt.table[, c] == cal$estado.p & cpt.table[, 1] == cal$estado.r
      cpt.table[idx, new_name] <- cal$score
      
      # --- Inferido (inferred) probability ---
      inf <- get_prob_data(probs, child.node, predictor, "Inferido")
      idx <- cpt.table[, c] == inf$estado.p & cpt.table[, 1] == inf$estado.r
      cpt.table[idx, new_name] <- inf$score
      
      # If there is an intermediate state combination (both parent and child),
      # assign the inferred score to that combination as well.
      if (!is.na(inf$estado.int.p) & !is.na(inf$estado.int.r)) {
        idx_int <- cpt.table[, c] == inf$estado.int.p &
          cpt.table[, 1] == inf$estado.int.r
        cpt.table[idx_int, new_name] <- inf$score
      }
    }
    
    # 4.7 Combine scores from all predictors to produce a final frequency (Freq)
    #     The sum of all predictor scores gives a total 'weight' for each combination.
    vars.scores <- ncol(cpt.table)
    # The score columns are from (vars+1) to vars.scores
    cpt.table$Freq <- rowSums(cpt.table[as.numeric(vars + 1):as.numeric(vars.scores)],
                              na.rm = TRUE)
    
    # 4.8 Adjust for uncertainty when child has more than two states:
    #     The maximum frequency becomes the base, and the remaining uncertainty
    #     is added to the intermediate state (if any).
    if (length(estados) > 2) {
      uncertainty <- 100 - max(cpt.table$Freq)
      # Find the intermediate state for the child (from calibrated data)
      cal <- get_prob_data(probs, child.node, predictor, "Calibrado")
      # Add uncertainty to rows where the child is in its intermediate state
      cpt.table[cpt.table[[child.node]] == cal$estado.int.r, "Freq"] <- 
        cpt.table[cpt.table[[child.node]] == cal$estado.int.r, "Freq"] + uncertainty
    }
    
    # 4.9 For binary states, ensure the probabilities sum to 100% by adjusting
    #     the other state to 100 - the calibrated frequency.
    if (length(estados) == 2) {
      # For binary, we set the 'other' state's frequency to complement the calibrated one.
      # Here we assume that the 'Inferido' state is the one to complement.
      inf <- get_prob_data(probs, child.node, predictor, "Inferido")
      # Find rows where child is in the 'inferred' response state and set to complement
      cpt.table[cpt.table[[child.node]] == inf$estado.r, "Freq"] <- 100 - 
        cpt.table[cpt.table[[child.node]] == cal$estado.r, "Freq"]
    }
    
    # 4.10 Optionally remove the intermediate score columns (they are no longer needed)
    #      and convert frequencies to probabilities (divide by 100).
    if (TRUE) {   # This flag allows removal of unnecessary columns 
      #(Set false if you want to check specific scores)
      # Drop all columns whose names start with "Score_"
      cpt.table <- cpt.table[, !grepl("Score_", names(cpt.table))]
      # Convert from percentage to probability (0-1)
      cpt.table$Freq <- cpt.table$Freq / 100
    }
    
    # 4.11 Write the final CPT back to the Excel workbook, replacing any existing sheet.
    wb <- loadWorkbook(main.excel.path)
    if (paste0("CPT_", child.node) %in% names(wb)) {
      removeWorksheet(wb, paste0("CPT_", child.node))
    }
    addWorksheet(wb, paste0("CPT_", child.node))
    writeData(wb, paste0("CPT_", child.node), cpt.table)
    saveWorkbook(wb, main.excel.path, overwrite = TRUE)
    
  }  # end if conditional node
}  # end for each node

cat(green('Script finalizado\n'))



