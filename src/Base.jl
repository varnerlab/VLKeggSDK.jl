function check(result::Some)::(Union{Nothing,T} where T <: Any)

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

    for line_index = (section_line_start + 1):(section_line_end - 1)
        line_item = file_buffer_array[line_index]
        push!(section_buffer, line_item)
    end

    # return -
    return section_buffer
end
