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
                if (length(reaction_string) != 0 && 
                    contains(reaction_string,";") == true)

                    # create a new Reaction wrapper -
                    reaction_wrapper = KEGGReaction()

                    # populate w/easy stuff -
                    reaction_wrapper.ec_number = ec_number
                    reaction_wrapper.kegg_reaction_number = rn_number

                    # parse the body string -
                    tmp_enzyme_name = string(split(reaction_string, ";")[1])
                    reaction_wrapper.kegg_enzyme_name = string(split(tmp_enzyme_name, "\t")[2])
                    
                    # split into forward and reverse strings -
                    tmp_full_reaction_string = lstrip(chomp(string(split(reaction_string, ";")[2])))
                    reaction_wrapper.kegg_reaction_markup = tmp_full_reaction_string

                    
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

function get_genes_in_organism_pathway(organism_code::String, pathway_code::String)::Some

    try

        # initialize -
        gene_list = Array{String,1}()

        # setup url -
        url_string = "$(_KEGG_LINK_URL)/$(organism_code)/$(pathway_code)"
        http_body = http_get_call_with_url(url_string) |> check
        if (isnothing(http_body) == true)
            return Some(nothing)
        end

        # split along the newline -
        tokenized_body = split(http_body,"\n")
        for token in tokenized_body
            fragment_array = split(token,"\t")
            if (length(fragment_array) > 1)
                gene_value = string(fragment_array[2])
                push!(gene_list, gene_value)
            end
        end
        
        # return -
        return Some(gene_list)

    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

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

function get_pathways_for_organism(organism_code::String)::Some

    try

        # initialize -
        pathway_array = Array{KEGGPathway,1}()

        # formulate the url -
        url_string = "$(_KEGG_LIST_URL)/pathway/$(organism_code)"

        # get http -
        http_body = http_get_call_with_url(url_string) |> check
        if (isnothing(http_body) == true)
            return Some(nothing)
        end

        # split along the newline -
        tokenized_body = split(http_body,"\n")
        for token in tokenized_body

            # split along the \t -
            fragment_array = split(string(token), "\t")
            if (length(fragment_array) == 2)
                
                # build -
                pathway_object = KEGGPathway()
                pathway_object.pathway_id = string(fragment_array[1])
                pathway_object.pathway_description = string(fragment_array[2])

                # cache -
                push!(pathway_array, pathway_object)
            end
        end
        
        # return -
        return Some(pathway_array)
        
    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end
# ------------------------------------------------------------------------------ #