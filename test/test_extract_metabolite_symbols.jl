using VLKeggSDK

# reaction -
reaction_phrase = "C00533 + C00014 + 3 C00126 <=> C05361 + C00001 + 3 C00125"

# get symbols -
symbol_array = extract_metabolite_symbols(reaction_phrase)