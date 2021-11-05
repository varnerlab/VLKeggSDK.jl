# -- PRIVATE METHODS ----------------------------------------------------------- #
function _process_gene_location(gene_location::String)::String

    # does the gene_location contain a .x?
    dot_index = findfirst(x -> x == '.', gene_location)
    if (isnothing(dot_index))
        return gene_location
    end

    # ok, we have a dot -
    bare_gene_location = gene_location[1:dot_index - 1]

    # return -
    return bare_gene_location
end
# ------------------------------------------------------------------------------ #

# -- PUBLIC METHODS ------------------------------------------------------------ #
function get_sequence_for_gene(gene_array::Array{String,1})::Some

    try

        # initialize -
        seq_obj_array = Array{KEGGSequence,1}()
        for gene in gene_array
            seq_obj = get_sequence_for_gene(gene) |> check
            if (isnothing(seq_obj) == false)
                push!(seq_obj_array, seq_obj)
            end
        end

        # return -
        return Some(seq_obj_array)
    catch error
    
        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_sequence_for_gene(gene_location::String)::Some

    # TODO: check gene string -

    try
        
        # gene seq - cutoff the trailing .x -
        kegg_gene_location = _process_gene_location(gene_location)
        if (isnothing(kegg_gene_location) == true)
            return Some(nothing)
        end

        # setup the url string -
        url_string = "$(_KEGG_GET_URL)/$(kegg_gene_location)/ntseq"

        # get the sequence -
        # returns: {header}\n{sequence_body}\n{?}
        ntseq = http_get_call_with_url(url_string) |> check
        if (length(ntseq) == 0)
            return Some(nothing)
        end

        # split on the newline -
        fragment_array = split(ntseq, '\n')

        # build new sequence type -
        sequence = KEGGSequence()
        sequence.gene_location = kegg_gene_location
        sequence.type = :gene
        sequence.header = fragment_array[1]
        
        # build seq string -
        seq_buffer = ""
        [seq_buffer *= string(x) for x in fragment_array[2:end - 1]]
        sequence.body = seq_buffer

        # return the sequence -
        return Some(sequence)

    catch error
        
        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_sequence_for_protein(gene_array::Array{String,1})::Some

    try

        # initialize -
        seq_obj_array = Array{KEGGSequence,1}()
        for gene in gene_array
            seq_obj = get_sequence_for_protein(gene) |> check
            if (isnothing(seq_obj) == false)
                push!(seq_obj_array, seq_obj)
            end
        end

        # return -
        return Some(seq_obj_array)
    catch error
    
        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end

function get_sequence_for_protein(gene_location::String)::Some

    # TODO: check gene string -

    try

        # gene seq - cutoff the trailing .x -
        kegg_gene_location = _process_gene_location(gene_location)
        if (isnothing(kegg_gene_location) == true)
            return Some(nothing)
        end

        # setup the url string -
        url_string = "$(_KEGG_GET_URL)/$(kegg_gene_location)/aaseq"

        # get the sequence -
        # returns: {header}\n{sequence_body}\n{?}
        aaseq = http_get_call_with_url(url_string) |> check
        if (length(aaseq) == 0)
            return Some(nothing)
        end

        # split on the newline -
        fragment_array = split(aaseq, '\n')

        # build new sequence type -
        sequence = KEGGSequence()
        sequence.gene_location = kegg_gene_location
        sequence.type = :protein
        sequence.header = fragment_array[1]

        # build seq string -
        seq_buffer = ""
        [seq_buffer *= string(x) for x in fragment_array[2:end - 1]]
        sequence.body = seq_buffer

        # return the sequence -
        return Some(sequence)

    catch eror

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)

    end
end
# ------------------------------------------------------------------------------ #
