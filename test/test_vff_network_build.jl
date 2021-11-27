using VLKeggSDK
using DataFrames
using ProgressMeter
using BSON

# path -
path_to_vff_file = "./test/network/Model.vff"

# load the file -
list_of_reactions = build_reaction_table_from_vff_file(path_to_vff_file) |> check

# build the metabolites table -
compound_record_array = Array{KEGGCompound,1}()
@showprogress "Metabolites: " for reaction_obj in list_of_reactions

    # get the reaction number -
    kegg_reaction_markup = reaction_obj.reaction_markup

    # get the compound symbols -
    tmp_compound_array = extract_metabolite_symbols(kegg_reaction_markup)
    compound_record = get_compound_records(tmp_compound_array) |> check
    if (isnothing(compound_record) == false)
        append!(compound_record_array, compound_record)
    end
end


# make a unique compound array -
unique_compound_array = Array{KEGGCompound,1}()
@showprogress "Cleaning: " for compound_object in compound_record_array

    # get a test_id -
    compound_test_id = compound_object.compound_id
    compound_not_in_list = true
    for object in unique_compound_array
        
        object_compound_id = object.compound_id
        if (isequal(object_compound_id,compound_test_id) == true)
            compound_not_in_list = false
            break
        end
    end

    if (compound_not_in_list == true)
        push!(unique_compound_array, compound_object)
    end
end

# sort by compound id -
sort!(unique_compound_array)

# Dump model to disk -
model = Dict{Symbol,Any}()
model[:compounds] = unique!((unique_compound_array |> DataFrame))
model[:reactions] = unique!((list_of_reactions |> DataFrame))

# setup path -
_PATH_TO_MODEL_FILE = "./test/model/model.bson"
bson(_PATH_TO_MODEL_FILE, model)
