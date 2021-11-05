using VLKeggSDK
using DataFrames

# test -
test_compund_array = [
    "C20820"    ;
    "C19376"    ;
    "C01799"    ;
    "C00092"    ;
    "C00085"    ;
    "C00031"    ;
    "C00002"    ;
    "C00001"    ;
    "C00003"    ;
    "C00004"    ;
]

# data -
record_components = (get_compound_records(test_compund_array) |> check) |> DataFrame