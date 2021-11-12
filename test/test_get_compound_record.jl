using VLKeggSDK
using DataFrames

# lookup the following compounds -
test_compund_array = [
    "cpd:C20820"
    "cpd:C19376"
    "cpd:C01799"
    "cpd:C00092"
    "cpd:C00085"
    "cpd:C00031"
    "cpd:C00002"
    "cpd:C00001"
    "cpd:C00003"
    "cpd:C00004"
    "cpd:C00092"
];

# get the data for these compounds -
record_components = (get_compound_records(test_compund_array) |> check) |> DataFrame