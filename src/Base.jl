function check(result::Some)::(Union{Nothing,T} where {T<:Any})

    # ok, so check, do we have an error object?
    # Yes: log the error if we have a logger, then throw the error. 
    # No: return the result.value

    # Error case -
    if (isa(something(result), Exception) == true)

        # get the error object -
        error_object = result.value

        # get the error message as a String -
        error_message = sprint(showerror, error_object, catch_backtrace())
        @error(error_message)

        # throw -
        throw(result.value)
    end

    # default -
    return result.value
end

function extract_db_file_section(file_buffer_array::Array{String,1}, single_line_section_marker::String)::Union{Nothing,String}

    # find the SECTION START on a single line -
    section_line_start = 1
    for (index, line) in enumerate(file_buffer_array)
        if (occursin(single_line_section_marker, line) == true)
            section_line_start = index
        end
    end

    # return -
    return section_line_start == 1 ? nothing : file_buffer_array[section_line_start]
end

function extract_db_file_section(file_buffer_array::Array{String,1}, start_section_marker::String,
    end_section_marker::String)::Array{String,1}

    # initialize -
    section_buffer = String[]

    # find the SECTION START AND END -
    section_line_start = 1
    section_line_end = 1
    for (index, line) in enumerate(file_buffer_array)

        if (occursin(start_section_marker, line) == true)
            section_line_start = index
        elseif (occursin(end_section_marker, line) == true || length(line) == index)
            section_line_end = index
        end
    end

    for line_index = (section_line_start+1):(section_line_end-1)
        line_item = file_buffer_array[line_index]
        push!(section_buffer, line_item)
    end

    # return -
    return section_buffer
end

function Base.:(==)(c1::KEGGCompound, c2::KEGGCompound)
    return ((c1.kegg_compound_name == c2.kegg_compound_name) &&
            (c1.kegg_compound_id == c2.kegg_compound_id) &&
            (c1.kegg_compound_formula == c2.kegg_compound_formula) &&
            (c1.kegg_compound_mw == c2.kegg_compound_mw))
end

function extract_metabolite_symbols(reaction_phrase::String)

    # initialize -
    metabolite_symbol_array = Array{String,1}()

    # ok, so we need to check - do we have a <=> in this reaction?
    if (contains(reaction_phrase, "<=>") == true)

        # ok, so if we get here, then we have a top level reaction phrase -
        # split this, and go down a level -
        reaction_components = string.(split(reaction_phrase, "<=>") .|> lstrip .|> rstrip)
        for reaction_component in reaction_components

            # get the symbols -
            values = extract_metabolite_symbols(reaction_component)
            for value in values
                push!(metabolite_symbol_array, value)
            end
        end
    elseif (contains(reaction_phrase, "+") == true)

        # ok, so if we get here, then we have a left or right reaction phrase
        # split this, and go down a level -
        reaction_components = string.(split(reaction_phrase, "+") .|> lstrip .|> rstrip)
        for reaction_component in reaction_components

            # get the symbols -
            values = extract_metabolite_symbols(reaction_component)
            for value in values
                push!(metabolite_symbol_array, value)
            end
        end
    elseif (isnumeric(reaction_phrase[1]) == true &&
            isequal(reaction_phrase[2], ' ') == true)

        # split -
        reaction_component = string.(split(reaction_phrase, ' ')[2])
        values = extract_metabolite_symbols(reaction_component)
        for value in values
            push!(metabolite_symbol_array, value)
        end
    else

        # finally -> we just have a symbol -
        return [reaction_phrase |> lstrip |> rstrip]
    end

    return metabolite_symbol_array
end
