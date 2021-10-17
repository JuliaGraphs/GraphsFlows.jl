using GraphsFlows
using Test
using Graphs
import SimpleTraits

using LinearAlgebra: diag
using SparseArrays: spzeros

using JuMP
import GLPK

const testdir = dirname(@__FILE__)

testgraphs(g) = [g, Graphs.Graph{UInt8}(g), Graphs.Graph{Int16}(g)]
testdigraphs(g) = [g, Graphs.DiGraph{UInt8}(g), Graphs.DiGraph{Int16}(g)]

for t in [
        "edmonds_karp",
        "dinic",
        "boykov_kolmogorov",
        "push_relabel",
        "maximum_flow",
        "multiroute_flow",
        "mincost",
        "mincut",
        ]
    tp = joinpath(testdir, "$(t).jl")
    include(tp)
end
