function build_metabolite_keggid_matching_table()::Some

    try

        # initialize -
        metabolite_matching_table = Dict{String,String}()

        # build the url -
        url_string = _KEGG_LIST_COMPOUND_URL

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
                tmp_compound_name = string(split(record, "\t")[1])
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

function get_compound_records(compound_array::Array{String,1})::Some

    try

        # initialize -
        kegg_object_array = Array{KEGGCompound,1}()

        # main loop -
        for compound in compound_array

            # build compound object -
            object = get_compound_records(compound) |> check

            # push -
            push!(kegg_object_array, object)
        end

        # return -
        return Some(kegg_object_array)

    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_compound_records(compound::String)::Some

    try

        # build url -
        url_string = "$(_KEGG_GET_URL)/$(compound)"

        # make the call -
        http_body = http_get_call_with_url(url_string) |> check
        if (isempty(http_body) == true)
            return Some(nothing)
        end

        # initailize -
        compound_object = KEGGCompound()

        # ok, so we need to split this around the \n
        record_components = split(http_body, "\n")
        compound_object.kegg_compound_id = compound

        # NAME is always the [2] -
        tmp_name = split(record_components[2], repeat(" ", 5))[2] |> lstrip |> rstrip |> lowercase
        compound_object.kegg_compound_name = (last(tmp_name) == ';') ? tmp_name[1:end-1] : tmp_name

        # FORMULA -> we need to scan to find the formula record -
        for record in record_components
            if (contains(record, "FORMULA") == true)
                compound_object.kegg_compound_formula = split(record, repeat(" ", 5))[2] |> lstrip |> rstrip
                break
            end
        end

        # MOL_WEIGHT -> we need to scan to find the mw recrod -
        for record in record_components
            if (contains(record, "MOL_WEIGHT") == true)
                compound_object.kegg_compound_mw = parse(Float64, (split(record, repeat(" ", 2))[2] |> lstrip |> rstrip))
            end
        end

        # return -
        return Some(compound_object)
    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end


function get_compound_records_for_reaction(reaction_code::String)::Some

    try


        # get the reaction object with metabolites in KEGG markup (not english names) -
        kegg_reaction_object = get_reaction_for_rn_number(reaction_code) |> check
        if (isnothing(kegg_reaction_object) == true)
            return Some(nothing)
        end

        # initialize -
        reaction_compound_record_array = Array{KEGGCompound,1}()

        # pool the forward and reverse reaction strings -
        tmp_reaction_phrase_pool = Array{String,1}()
        push!(tmp_reaction_phrase_pool, kegg_reaction_object.reaction_forward)
        push!(tmp_reaction_phrase_pool, kegg_reaction_object.reaction_reverse)

        # build a local metabolite code pool -
        local_metabolite_code_pool = Array{String,1}()
        for reaction_phrase in tmp_reaction_phrase_pool
            
            # split around the + and strip space -
            compound_code_array = split(reaction_phrase,"+")
            for raw_compound_code in compound_code_array

                # turn code into string, strip spaces -
                tmp_code = string(raw_compound_code) |> lstrip |> rstrip

                # cache -
                value = "cpd:$(tmp_code)"
                push!(local_metabolite_code_pool, value)
            end
        end

        for metabolite_code in local_metabolite_code_pool
            compound_record = get_compound_records(metabolite_code) |> check
            if (isnothing(compound_record) == true)
                return Some(nothing)
            end
            push!(reaction_compound_record_array, compound_record)
        end

        return Some(reaction_compound_record_array)

    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end