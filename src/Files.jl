function build_reaction_table_from_vff_file(path_to_vff_file::String)::Some

    try

        # initialize -
        kegg_reaction_array = Array{KEGGReaction,1}()

        # get file buffer (array of strings) -
        vff_file_buffer = read_file_from_path(path_to_vff_file)

        # process -
        for reaction_line in vff_file_buffer

            # build KEGG reaction -
            reaction_object = KEGGReaction()

            # populate the data fields, store the reaction objects in an array 
            
            # skip comments and empty lines -
            if (occursin("//", reaction_line) == false && 
                isempty(reaction_line) == false)
            
                # split -
                reaction_components = string.(split(reaction_line, ","))

                # ecnumber -
                ec_number = reaction_components[1]
                if (isnothing(ec_number) == true)
                    reaction_object.ec_number = missing
                else
                    reaction_object.ec_number = ec_number
                end

                @show reaction_components

                # reaction number -
                rn_number = reaction_components[2]
                isnothing(rn_number) ? reaction_object.reaction_number = missing : reaction_object.reaction_number = rn_number

                # enzyme_name -
                enzyme_name = reaction_components[3]
                isnothing(enzyme_name) ? reaction_object.enzyme_name = missing : reaction_object.enzyme_name = enzyme_name

                # reaction_markup -
                reaction_markup = reaction_components[4]
                isnothing(reaction_markup) ? reaction_object.reaction_markup = missing : reaction_object.reaction_markup = reaction_markup

                # skip the rest if we have no reaction ...
                if (isnothing(reaction_markup) == false)
                    
                    # ok, for the next fields, we need to do a little parsing ... split around <=>
                    reaction_phrases = string.(split(reaction_markup, "<=>") .|> lstrip .|> rstrip)
                
                    # reactant phrase -
                    left_phrase = reaction_phrases[1]
                    isnothing(left_phrase) ? reaction_object.reaction_forward = missing : reaction_object.reaction_forward = left_phrase

                    # product phrase -
                    right_phrase = reaction_phrases[2]
                    isnothing(right_phrase) ? reaction_object.reaction_reverse = missing : reaction_object.reaction_reverse = right_phrase

                    # build the stoichiometric_dictionary -
                    stoichiometric_dictionary = extract_stoichiometric_dictionary(reaction_markup)
                    reaction_object.stoichiometric_dictionary = stoichiometric_dictionary

                    # grab -
                    push!(kegg_reaction_array, reaction_object)
                end
            end
        end

        # return -
        return Some(kegg_reaction_array)

    catch error

        # get the original error message -
        error_message = sprint(showerror, error, catch_backtrace())
        vl_error_obj = ErrorException(error_message)

        # Package the error -
        return Some(vl_error_obj)
    end
end