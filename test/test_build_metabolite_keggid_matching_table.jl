using VLKeggSDK
using ProgressMeter
using DataFrames

# get matching table -
metabolite_matching_table = build_metabolite_keggid_matching_table() |> check

# compute the master compound table -
master_compound_array = Array{KEGGCompound,1}()
value_itr = values(metabolite_matching_table)
@showprogress for kegg_compound_code in value_itr

    # mod_code -
    mod_compund_code = "cpd:$(kegg_compound_code)"

    # grab from cloud -
    kegg_compound_obj = get_compound_records(mod_compund_code) |> check
    if (isnothing(kegg_compound_obj) == false)
        push!(master_compund_array, kegg_compound_obj)
    end
end