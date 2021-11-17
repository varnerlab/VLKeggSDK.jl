# get_ec_number_for_gene
function get_ec_number_for_gene(gene_array::Array{String,1})::Some

    try

        # initialize -
        ec_number_array = Array{String,1}()
        for gene in gene_array

            local_ec_number_array = get_ec_number_for_gene(gene) |> check
            if (isnothing(local_ec_number_array) == false)
                for ec_number in local_ec_number_array
                    push!(ec_number_array, ec_number)
                end
            end
        end

        return Some(ec_number_array)
    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_ec_number_for_gene(gene_location::String)::Some

    # TODO: check gene location string -

    try

        # curl -X GET http://rest.kegg.jp/link/ec/eco:b2388  => ec for this gene
        # curl -X GET http://rest.kegg.jp/link/eco/eco00010  => genes for a pathway

        # initialize -
        ec_number_array = String[]

        # formulate the url -
        url_string = "$(_KEGG_LINKAGE_EC_URL)/$(gene_location)"

        # get the data -
        ecdata = http_get_call_with_url(url_string) |> check
        if (ecdata == "\n" || isnothing(ecdata) == true)
            return Some(nothing)
        end

        # ok, parse the response which is of the form: {gene_location}\t{ec_number}\n*
        # we can have more than 1 record -
        record_array = split(ecdata, "\n")

        # process the records -
        for record in record_array

            # split along the \t -
            if (record != "")
                ec_number = string(split(record, "\t")[2])
                push!(ec_number_array, ec_number)
            end
        end

        # return this record -
        return Some(ec_number_array)

    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_ec_numbers_for_pathway(pathway_code_array::Array{String,1})::Some

    try

        # master ec numner list -
        master_ec_number_list = Array{String,1}()

        # process the list of pathways -
        for pathway_code in pathway_code_array
            
            # get ec number array -
            ec_number_array = get_ec_numbers_for_pathway(pathway_code) |> check
            if (isnothing(ec_number_array) == false)
                append!(master_ec_number_list, ec_number_array)
            end
        end

        # return -
        return Some(master_ec_number_list)
    catch error
    
        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_ec_numbers_for_pathway(pathway_code::String)::Some

    try

        # initialize -
        ec_number_array = Array{String,1}()

        # formulate the url -
        url_string = "$(_KEGG_LINK_URL)/ec/$(pathway_code)"

        # execute the call -
        http_body_call = http_get_call_with_url(url_string) |> check
        if (http_body_call == "\n" || isnothing(http_body_call) == true)
            return Some(nothing)
        end

        # split along the new line 
        record_array = split(http_body_call,"\n")
        if (isnothing(record_array) == true || length(record_array) == 0)
            return Some(nothing)
        end
        for record in record_array
            
            # split again along the tab -
            record_components = split(record,"\t")
            
            if (length(record_components) == 2)
                
                # the ec number is the second element -
                ec_number_value = string(record_components[2])

                # grab -
                push!(ec_number_array,ec_number_value)
            end
        end

        # wrap and return -
        return Some(ec_number_array)

    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end