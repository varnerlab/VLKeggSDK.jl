using VLKeggSDK
using DataFrames

# get pathways for E. coli -
organism_code = "eco"

# get codes -
pathway_table = get_pathways_for_organism(organism_code) |> check |> DataFrame