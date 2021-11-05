function build_metabolite_keggid_matching_table()::Some

    try
        
        # initialize -
        metabolite_matching_table = Dict{String,String}()

        # build the url -
        url_string = _KEGG_COMPOUND_URL

        # make the call -
        http_body = http_get_call_with_url(url_string) |> check

        # ok, so no body?
        if (length(http_body) == 0)
            return Some(nothing)
        end

        # populate the table -
        records_array = split(http_body, "\n")
        for record in records_array

            # records take the form:
            # kegg_compound_id\t{Names;*}

            if (record != "")
                # split around the \t -
                tmp_compound_name =  string(split(record, "\t")[1])
                kegg_compound_id = string(split(tmp_compound_name, ":")[2])
                compound_name_array = split(record, "\t")[2]
                if (occursin(";", compound_name_array) == true)

                    # ok, so we have multiple possible names -
                    synomym_array = split(compound_name_array, ";")
                    for synonum in synomym_array
                        metabolite_matching_table[lowercase(lstrip(string(synonum)))] = kegg_compound_id
                    end
                else
                    metabolite_matching_table[lowercase(lstrip(string(compound_name_array)))] = kegg_compound_id
                end
            end
        end

        # return -
        return Some(metabolite_matching_table)
    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end


    
end