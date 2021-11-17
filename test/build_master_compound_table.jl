using VLKeggSDK
using DataFrames
using ProgressMeter

# get all the compounds in the database -
master_compound_dictionary = build_metabolite_keggid_matching_table() |> check

# so we need to make sure that *+ compounds have the * synonum in the collection -
for (key, value) in master_compund_dictionary

    if (contains(key, "+") == true)

        # build a new key -
        new_key = replace(key, "+" => "")

        # add the new key to the dict -
        master_compound_dictionary[new_key] = value
    end
end