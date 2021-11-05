using VLKeggSDK

# get matching table -
metabolite_matching_table = build_metabolite_keggid_matching_table() |> check