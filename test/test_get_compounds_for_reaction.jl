using VLKeggSDK
using DataFrames

# setup an array of ec numbers -
rn_number_array = [
    "rn:R00299"
    "rn:R00771"
    "rn:R04779"
    "rn:R01068"
]

Z = get_compound_records_for_reaction(rn_number_array[1]) |> check
