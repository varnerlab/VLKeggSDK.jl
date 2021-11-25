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

function read_file_from_path(path_to_file::String)::Array{String,1}

    # initialize -
    buffer = String[]

    # Read in the file -
    open("$(path_to_file)", "r") do file
        for line in eachline(file)
            +(buffer,line)
        end
    end

    # return -
    return buffer
end

function +(buffer::Array{String,1}, content_array::Array{String,1})
    for line in content_array
        push!(buffer, line)
    end
end

function +(buffer::Array{String,1}, line::String)
    push!(buffer, line)
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
    return ((c1.compound_name == c2.compound_name) &&
            (c1.compound_id == c2.compound_id) &&
            (c1.compound_formula == c2.compound_formula) &&
            (c1.compound_mw == c2.compound_mw))
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

function extract_stoichiometric_dictionary(reaction_phrase::String, 
    direction::Symbol = :reactants)

    # initialize -
    stoichiometric_dictionary = Dict{String,Any}()

    # ok, so we need to check - do we have a <=> in this reaction?
    if (contains(reaction_phrase, "<=>") == true)

        # ok, so if we get here, then we have a top level reaction phrase -
        # split this, and go down a level -
        reaction_components = string.(split(reaction_phrase, "<=>") .|> lstrip .|> rstrip)
        for (index, reaction_component) in enumerate(reaction_components)

            # setup the direction -
            index == 1 ? direction = :reactants : direction = :products

            # get the symbols -
            value_dictionary = extract_stoichiometric_dictionary(reaction_component, direction)
            for (key, value) in value_dictionary
                stoichiometric_dictionary[key] = value
            end
        end
    elseif (contains(reaction_phrase, "+") == true)

        # ok, so if we get here, then we have a left or right reaction phrase
        # split this, and go down a level -
        reaction_components = string.(split(reaction_phrase, "+") .|> lstrip .|> rstrip)
        for reaction_component in reaction_components

            # get the symbols -
            value_dictionary = extract_stoichiometric_dictionary(reaction_component, direction)
            for (key, value) in value_dictionary
                stoichiometric_dictionary[key] = value
            end
        end
    elseif (length(reaction_phrase) >= 2 &&
            isnumeric(reaction_phrase[1]) == true &&
            isequal(reaction_phrase[2], ' ') == true)

        # what is my multiple?
        direction == :reactants ? α = -1 : α = 1

        # split -
        st_value = string.(split(reaction_phrase, ' ')[1])
        metabolite_key = string.(split(reaction_phrase, ' ')[2])

        # if we get here, then we have a coefficient -
        stoichiometric_coefficient = α * parse(Float64, st_value)

        # add to dictionary -
        stoichiometric_dictionary[metabolite_key] = stoichiometric_coefficient

    else

        # when we get here, we just have a single bare metabolite -

        # what is my multiple?
        direction == :reactants ? α = -1 : α = 1

        # if we get here, then we have a coefficient -
        stoichiometric_coefficient = α * 1.0
        metabolite_key = reaction_phrase

        # finally -> we just have a symbol -
        stoichiometric_dictionary[metabolite_key] = stoichiometric_coefficient
    end

    # remove spaces ... not sure where this is coming from ... but this hack should fix ...    
    delete!(stoichiometric_dictionary, "")

    # return -
    return stoichiometric_dictionary
end

function extract_atom_dictionary(formula::String)

    # test -
    atom_dictionary = Dict()
    local_array = Array{Char,1}()
    element_key_array = Array{Char,1}()

    # turn string into char array -
    formula_char_array = collect(formula)

    # add extra 1 if last char is a letter -
    if (isnumeric(last(formula_char_array)) == false)
        push!(formula_char_array, '1')
    end

    # read from the bottom -
    reverse!(formula_char_array)

    # how many chars do we have?
    while (isempty(formula_char_array) == false)

        # clean out the array from the last pass -
        empty!(local_array)
        empty!(element_key_array)

        # grab the next value -
        next_value = pop!(formula_char_array)
        if (isnumeric(next_value) == false)

            # we have an element -> read until I hit another element -
            is_ok_to_loop = true
            while (is_ok_to_loop)

                if (isempty(formula_char_array) == true)
                    break
                end

                read_one_ahead = pop!(formula_char_array)
                if (isnumeric(read_one_ahead) == true)
                    push!(local_array, read_one_ahead)
                else

                    # ok: so if we get here - then we read the next char, but it was a 
                    # letter (element) - so we need to push it back on the stack ...
                    push!(formula_char_array, read_one_ahead)

                    # shutodown -
                    is_ok_to_loop = false
                end
            end
        end

        # we need to turn local array into a string -
        buffer = ""
        [buffer *= string(x) for x in local_array]
        if (isempty(buffer) == false)
            atom_dictionary[string(next_value)] = parse(Int64, buffer)
        end
    end

    # return -
    return atom_dictionary
end