using Documenter
using GraphsFlows
using Graphs

makedocs(
    modules = [GraphsFlows],
    format = Documenter.HTML(),
    sitename = "GraphsFlows",
	pages = Any[
		"Getting started"    => "index.md",
        "Maxflow algorithms" => "maxflow.md",
        "Multiroute flows"   => "multiroute.md",
        "Min-cost flows"     => "mincost.md",
        "Min-cut"            => "mincut.md",
    ]
)

deploydocs(
    deps        = nothing,
    make        = nothing,
    repo        = "github.com/JuliaGraphs/GraphsFlows.jl.git",
    versions = ["stable" => "v^", "v#.#", "dev" => "master"],
)
