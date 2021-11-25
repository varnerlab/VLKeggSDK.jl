using VLKeggSDK
using DataFrames

# path -
path_to_vff_file = "./test/network/Test.vff"

# load the file -
list_of_reactions = build_reaction_table_from_vff_file(path_to_vff_file) |> check |> DataFrame

