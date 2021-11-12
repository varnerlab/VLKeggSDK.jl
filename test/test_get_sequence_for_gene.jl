using VLKeggSDK
using DataFrames

# specify a list of genes (notice this has the KEGG organism code prepended) -
gene_array = [
    "eco:b2388"
]

# DNA sequence for each gene in the list of genes -> piped to a DataFrame
# DNA sequence is a BioSequences.LongDNASeq type -
gene_table = get_sequence_for_gene(gene_array) |> check |> DataFrame

# Protein sequence for each gene in the list of genes -> piped to a DataFrame
# Protein sequence is a BioSequences.LongAminoAcidSeq  -
protein_table = get_sequence_for_protein(gene_array) |> check |> DataFrame