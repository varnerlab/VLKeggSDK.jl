using VLKeggSDK


# test reaction -
reaction_phrase = "C00533 + C00014 + 3 C00126 <=> C05361 + C00001 + 3 C00125"

# go -
std = extract_stoichiometric_dictionary(reaction_phrase)