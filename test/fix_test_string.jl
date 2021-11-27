function _fix_compound_string(chars::Array{Char,1})

    # init tmp
    tmp_array = Array{Char,1}()

    @show chars

    if (isempty(chars) == true)
        return tmp_array
    end

    # get next char -
    next_char = pop!(chars)
    if (isnumeric(next_char) == true)

        push!(tmp_array, next_char)

        values = _fix_compound_string(chars)
        for value in values
            push!(tmp_array, value)
        end
        
    elseif (isnumeric(next_char) == false)
        
        # ok, so pop another char -
        next_next_char = pop!(chars)
        if (isnumeric(next_next_char) == false)
            
            push!(tmp_array, next_char)
            push!(tmp_array, '1')
            
            # push the test char back onto the stack -
            push!(chars, next_next_char)
        else
            push!(tmp_array, next_char)
            push!(tmp_array, next_next_char)
        end
        
        values = _fix_compound_string(chars)
        for value in values
            push!(tmp_array, value)
        end
    end

    # return -
    return tmp_array
end

#test_char_array = "C5H12O8P2" |> collect
#test_char_array = "KOH" |> collect
test_char_array = "H3PO4" |> collect

# add extra 1 if last char is a letter -
if (isnumeric(last(test_char_array)) == false)
    push!(test_char_array, '1')
end

C_tmp = _fix_compound_string(reverse(test_char_array))
