using VLKeggSDK
using DataFrames

# setup an array of ec numbers -
rn_number_array = [
    "rn:R00299"
    "rn:R00771"
    "rn:R04779"
    "rn:R01068"
]

# download these reactions -
reaction_array = get_reaction_for_rn_number(rn_number_array) |> check |> DataFrame