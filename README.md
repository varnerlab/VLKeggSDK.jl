# VLKeggSDK.jl
`VLKeggSDK.j` is a software Development Kit (SDK) for the Kyoto Encyclopedia of Genes and Genomes (KEGG).
The [Kyoto Encyclopedia of Genes and Genomes (KEGG)](https://www.kegg.jp/kegg/kegg1.html)
provides a [REST-style Application Programming Interface (API)](https://www.kegg.jp/kegg/rest/keggapi.html)
for custom queries against the various KEGG databases. This package provides a [Julia](https://julialang.org) interface to the KEGG RESTful API.

### Installation
``VLKeggSDK.jl`` is organized as a [Julia](http://julialang.org) package which can be installed in the ``package mode`` of Julia.

Start of the [Julia REPL](https://docs.julialang.org/en/v1/stdlib/REPL/index.html) and enter the ``package mode`` using the ``]`` key (to get back press the ``backspace`` or ``^C`` keys). Then, at the prompt enter:

    (v1.x) pkg> add VLKeggSDK

This will install the ``VLKeggSDK.jl`` package and the other required packages. ``VLConstraintBasedModelGenerationUtlities.jl`` requires Julia 1.6.x and above. The ``VLKeggSDK`` package is open source. You can download this repository as a zip file, or clone or pull it by using the command (from the command-line):

	$ git pull https://github.com/varnerlab/VLKeggSDK.jl

or

	$ git clone https://github.com/varnerlab/VLKeggSDK.jl


### Functions

### Examples

##### Download and parse reactions in a organism and pathway

```julia
using VLKeggSDK
using DataFrames

# Setup: Let's look at glycolysis in E. coli
organism_code = "eco"
pathway_code = "eco00010"

# First, get the list of genes for this organism and pathway (glycolysis in E. coli)
eco_gene_list = get_genes_in_organism_pathway(organism_code, pathway_code) |> check

# Next, get the list of ec's associated with these genes -
ec_number_list = get_ec_number_for_gene(eco_gene_list) |> check

# Finally, get the reactions -> returned as a DataFrame
reaction_table = get_reactions_for_ec_number(ec_number_list) |> check |> DataFrame
```

### Funding
The work described was supported by the [Center on the Physics of Cancer Metabolism at Cornell University](https://psoc.engineering.cornell.edu) through Award Number 1U54CA210184-01 from the [National Cancer Institute](https://www.cancer.gov). The content is solely the responsibility of the authors and does not necessarily
represent the official views of the [National Cancer Institute](https://www.cancer.gov) or the [National Institutes of Health](https://www.nih.gov).
