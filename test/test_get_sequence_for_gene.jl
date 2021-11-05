using VLKeggSDK
using DataFrames

# test -
gene_array = [
    "eco:b2388"
]

# run -
gene_table = get_sequence_for_gene(gene_array) |> check |> DataFrame
protein_table = get_sequence_for_protein(gene_array) |> check |> DataFrame