# --- PUBLIC METHODS ----------------------------------------------------------- #
function get_reactions_for_ec_number(ec_number_array::Array{String,1})::Some

    try

        # no ec numbers ... then no reactions!
        if (isempty(ec_number_array) == true)
            return Some(nothing)
        end

        # initialize -
        reaction_array = Array{KEGGReaction,1}()

        # process -
        for ec_number in ec_number_array
            
            # do we have an error?
            local_reaction_array = get_reactions_for_ec_number(ec_number) |> check

            # no - then, if this is not nothing, add -
            if (isnothing(reaction_array) == false)
                for reaction in local_reaction_array
                    push!(reaction_array, reaction)
                end
            end
        end

        # return -
        return Some(reaction_array)

    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_reactions_for_ec_number(ec_number::String)::Some

    try

        # Check: does this contain a ec: prefix? Yes, chop it off -
        local_ec_number = ec_number
        if (occursin("ec:", ec_number) == true)
            local_ec_number = ec_number[4:end]
        end

        # initalize -
        record_array = KEGGReaction[]

        # formulate url -
        linkage_url_string = "$(_KEGG_LINKAGE_REACTION_URL)/$(local_ec_number)"

        # call to get linkage array -
        ec_rn_linkage_array = http_get_call_with_url(linkage_url_string) |> check

        # if the server returned something, it should be in the form ec# rn#
        # we need the rn# to pull down the reaction string -
        if (length(ec_rn_linkage_array) > 1)

            # ec_rn_linkage can have more than one association -
            # split around the \n, and then process each item
            P = reverse(split(chomp(ec_rn_linkage_array), '\n'))
            while (!isempty(P))

                # pop -
                local_record = pop!(P)

                # The second fragment is the rn# -
                # split around the \t
                rn_number = string(split(local_record, '\t')[2])

                # ok, run a second query to pull the reaction string down -
                reaction_string = chomp((http_get_call_with_url("$(_KEGG_LIST_URL)/$(rn_number)")) |> check)

                # if we have something in reaction string, create a string record -
                if (length(reaction_string) != 0)

                    # create a new Reaction wrapper -
                    reaction_wrapper = KEGGReaction()

                    # populate w/easy stuff -
                    reaction_wrapper.ec_number = ec_number
                    reaction_wrapper.kegg_reaction_number = rn_number

                    # parse the body string -
                    reaction_wrapper.kegg_enzyme_name = string(split(reaction_string, ";")[1])
                    reaction_wrapper.kegg_reaction_markup = lstrip(chomp(string(split(reaction_string, ";")[2])))

                    # cache -
                    push!(record_array, reaction_wrapper)
                end
            end
        end

        # check - zero entries?
        if (length(record_array) == 0)
            return Some(nothing)
        end

        # return list of records -
        return Some(record_array)
    catch error
        
        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

# get_ec_number_for_gene
function get_ec_number_for_gene(gene_location::String)::Some

    # TODO: check gene location string -

    try
        
        # initialize -
        ec_number_array = String[]

        # formulate the url -
        url_string = "$(_KEGG_LINKAGE_EC_URL)/$(gene_location)"

        # get the sequence -
        ecdata = http_get_call_with_url(url_string)

        # check: do we have only the new line? Yes, then return nothing
        if (ecdata == "\n")
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
# ------------------------------------------------------------------------------ #