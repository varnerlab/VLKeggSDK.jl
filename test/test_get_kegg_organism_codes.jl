using VLKeggSDK
using DataFrames

# get codes -
ca = (get_kegg_organism_codes() |> check) |> DataFrame