using VLKeggSDK
using DataFrames

# setup an array of ec numbers -
rn_number_array = [
    "rn:R00299"
    "rn:R00771"
    "rn:R04779"
    "rn:R01068"
]

# initialize -
compound_record_array = Array{KEGGCompound,1}()
for rn_number in rn_number_array

    # get the compound records -
    compound_record = get_compound_records_for_reaction(rn_number) |> check
    if (isnothing(compound_record) == false)
        append!(compound_record_array, compound_record)
    end
end

# update -
unique!(compound_record_array)


