# --- PUBLIC METHODS ----------------------------------------------------------- #
function get_reaction_for_rn_number(rn_number_array::Array{String,1})::Some

    try

        # initialize -
        reaction_object_array = Array{KEGGReaction,1}()
        for rn_number in rn_number_array
            rxn_object = get_reaction_for_rn_number(rn_number) |> check
            if (isnothing(rxn_object) == false)
                push!(reaction_object_array, rxn_object)
            end
        end

        # return -
        return Some(reaction_object_array)
    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_reaction_for_rn_number(rn_number::String)::Some

    try

        # initialize -
        kegg_reaction = KEGGReaction()
        kegg_reaction.reaction_number = rn_number

        # formulae the URL string -
        url_string = "$(_KEGG_GET_URL)/$(rn_number)"

        # make the call -
        http_body = http_get_call_with_url(url_string) |> check
        if (isempty(http_body) == true)
            return Some(nothing)
        end

        # split around the \n -
        record_array = string.(split(http_body, "\n"))

        # grab: equation section -
        equation_section = extract_db_file_section(record_array, "EQUATION")
        if (isnothing(equation_section) == true)
            return Some(nothing)
        end
        rxn_string = string(split(equation_section, repeat(" ", 3))[2] |> lstrip)
        kegg_reaction.reaction_markup = rxn_string

        # reaction components -
        rxn_component_array = string.(split(rxn_string, " <=> "))
        kegg_reaction.reaction_forward = rxn_component_array[1]
        kegg_reaction.reaction_reverse = rxn_component_array[2]

        # grab: enzyme section -> ec number 
        enzyme_section = extract_db_file_section(record_array, "ENZYME")
        if (isnothing(enzyme_section) == true)
            return Some(nothing)
        end
        tmp_ec_number = string(split(enzyme_section, repeat(" ", 4))[2] |> lstrip)
        kegg_reaction.ec_number = "ec:$(tmp_ec_number)"

        # grab: enzyme name -
        name = extract_db_file_section(record_array, "NAME")
        kegg_reaction.enzyme_name = string(split(name, repeat(" ", 5))[2] |> lstrip)

        # build the st dictionary -
        std = extract_stoichiometric_dictionary(rxn_string)
        kegg_reaction.stoichiometric_dictionary = std

        # return -
        return Some(kegg_reaction)

    catch error
        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

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
            if (isnothing(local_reaction_array) == false)
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
                if (length(reaction_string) != 0 &&
                    contains(reaction_string, ";") == true)

                    # create a new Reaction wrapper -
                    reaction_wrapper = KEGGReaction()

                    # populate w/easy stuff -
                    reaction_wrapper.ec_number = ec_number
                    reaction_wrapper.reaction_number = rn_number

                    # parse the body string -
                    tmp_enzyme_name = string(split(reaction_string, ";")[1])
                    reaction_wrapper.enzyme_name = string(split(tmp_enzyme_name, "\t")[2])

                    # split into forward and reverse strings -
                    tmp_full_reaction_string = lstrip(chomp(string(split(reaction_string, ";")[2])))
                    reaction_wrapper.reaction_markup = tmp_full_reaction_string

                    tmp_string_frag = split(tmp_full_reaction_string, " <=> ")
                    if (length(tmp_string_frag) == 2)

                        # forward -
                        reaction_wrapper.reaction_forward = lowercase(string(tmp_string_frag[1]))

                        # reverse -
                        reaction_wrapper.reaction_reverse = lowercase(string(tmp_string_frag[2]))
                    else
                        reaction_wrapper.reaction_forward = missing
                        reaction_wrapper.reaction_reverse = missing
                    end

                    # for now ...
                    tmp_reaction_string = "$(reaction_wrapper.reaction_forward) <=> $(reaction_wrapper.reaction_reverse)"
                    reaction_wrapper.stoichiometric_dictionary = extract_stoichiometric_dictionary(tmp_reaction_string)

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
# ------------------------------------------------------------------------------ #