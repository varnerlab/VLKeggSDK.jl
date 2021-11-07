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