using VLKeggSDK
using DataFrames

# setup an array of ec numbers -
ec_number_array = [
    "ec:2.7.1.2"   ;
    "ec:5.3.1.9"   ;
    "ec:2.7.1.11"  ;
    "ec:4.1.2.13"  ;
]

# download these reactions -
reaction_array = get_reactions_for_ec_number(ec_number_array) |> check

# build data table -
data_table = DataFrame(reaction_array)