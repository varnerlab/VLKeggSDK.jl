function get_kegg_organism_codes()::Some

    try

        # initialize -
        organism_array = Array{KEGGOrganism,1}()

        # formulate the URL -
        url_string = "$(_KEGG_LIST_URL)/organism"

        # make the call -
        http_body = http_get_call_with_url(url_string) |> check
        if (isnothing(http_body) == true)
            return Some(nothing)
        end

        # split along the newline -
        tokenized_body = split(http_body,"\n")
        for record in tokenized_body

            # record -
            # {Txxx}\t{organism code}\t{description}\t{species_taxonomy}

            # ok, we need to cut again, along the \t -
            field_array = split(record,"\t")

            # check, do we have 4 elements -
            if (length(field_array) == 4)

                # create new organism -
                organism_wrapper = KEGGOrganism()
                organism_wrapper.organism_id = field_array[1]
                organism_wrapper.species_description = field_array[3]
                organism_wrapper.species_taxonomy = field_array[4]

                # # grab the organism_code -
                organism_code = field_array[2]
                organism_wrapper.organism_code = organism_code

                # cache -
                push!(organism_array, organism_wrapper)
            end
        end

        # return -
        return Some(organism_array)

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
        tokenized_body = split(http_body, "\n")
        for token in tokenized_body
            fragment_array = split(token, "\t")
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
        tokenized_body = split(http_body, "\n")
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