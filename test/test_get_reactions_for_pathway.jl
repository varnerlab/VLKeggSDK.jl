using VLKeggSDK
using DataFrames

# Setup: Let's look at glycolysis in E. coli
organism_code = "eco"
pathway_code = "eco00010"

# First, get the list of genes for this organism and pathway (glycolysis in E. coli)
eco_gene_list = get_genes_in_organism_pathway(organism_code, pathway_code) |> check

# Next, get the list of ec's associated with these genes -
ec_number_list = get_ec_number_for_gene(eco_gene_list) |> check

# Finally, get the reactions -
reaction_table = get_reactions_for_ec_number(ec_number_list) |> check |> DataFrame
