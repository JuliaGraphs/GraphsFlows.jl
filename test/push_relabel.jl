@testset "Push relabel" begin
    # Construct DiGraph
    flow_graph = Graphs.DiGraph(8)

    # Load custom dataset
    flow_edges = [
        (1, 2, 10), (1, 3, 5), (1, 4, 15), (2, 3, 4), (2, 5, 9),
        (2, 6, 15), (3, 4, 4), (3, 6, 8), (4, 7, 16), (5, 6, 15),
        (5, 8, 10), (6, 7, 15), (6, 8, 10), (7, 3, 6), (7, 8, 10)
    ]

    capacity_matrix = zeros(Int, 8, 8)

    for e in flow_edges
        u, v, f = e
        Graphs.add_edge!(flow_graph, u, v)
        capacity_matrix[u, v] = f
    end
    for g in testdigraphs(flow_graph)
      residual_graph = @inferred(GraphsFlows.residual(g))

      # Test enqueue_vertex
      Q = Array{Int,1}()
      excess = [0, 1, 0, 1]
      active = [false, false, true, true]
      @test @inferred(GraphsFlows.enqueue_vertex!(Q, 1, active, excess)) == nothing
      @test @inferred(GraphsFlows.enqueue_vertex!(Q, 3, active, excess)) == nothing
      @test @inferred(GraphsFlows.enqueue_vertex!(Q, 4, active, excess)) == nothing
      @test length(Q) == 0
      @test @inferred(GraphsFlows.enqueue_vertex!(Q, 2, active, excess)) == nothing
      @test length(Q) == 1

      # Test push_flow
      Q = Array{Int,1}()
      excess = [15, 1, 1, 0, 0, 0, 0, 0]
      height = [8, 0, 0, 0, 0, 0, 0, 0]
      active = [true, false, false, false, false, false, false, true]
      flow_matrix = zeros(Int, 8, 8)
      @test @inferred(GraphsFlows.push_flow!(residual_graph, 1, 2, capacity_matrix, flow_matrix, excess, height, active, Q)) == nothing
      @test length(Q) == 1
      @test flow_matrix[1, 2] == 10
      @test @inferred(GraphsFlows.push_flow!(residual_graph, 2, 3, capacity_matrix, flow_matrix, excess, height, active, Q)) == nothing
      @test length(Q) == 1
      @test flow_matrix[2, 3] == 0

      # Test gap
      Q = Array{Int,1}()
      excess = [15, 1, 1, 0, 0, 0, 0, 0]
      height = [8, 2, 2, 1, 3, 3, 4, 5]
      active = [true, false, false, false, false, false, false, true]
      count  = [0, 1, 2, 2, 1, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
      flow_matrix = zeros(Int, 8, 8)

      @test @inferred(GraphsFlows.gap!(residual_graph, 1, excess, height, active, count, Q)) == nothing
      @test length(Q) == 2

      # Test relabel
      Q = Array{Int,1}()
      excess = [15, 1, 1, 0, 0, 0, 0, 0]
      height = [8, 1, 1, 1, 1, 1, 1, 0]
      active = [true, false, false, false, false, false, false, true]
      count  = [1, 6, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
      flow_matrix = zeros(Int, 8, 8)

      @test @inferred(GraphsFlows.relabel!(residual_graph, 2, capacity_matrix, flow_matrix, excess, height, active, count, Q)) == nothing
      @test length(Q) == 1

      # Test discharge
      Q = Array{Int,1}()
      excess = [50, 1, 1, 0, 0, 0, 0, 0]
      height = [8, 0, 0, 0, 0, 0, 0, 0]
      active = [true, false, false, false, false, false, false, true]
      count  = [7, 0, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0, 0, 0]
      flow_matrix = zeros(Int, 8, 8)

      @test @inferred(GraphsFlows.discharge!(residual_graph, 1, capacity_matrix, flow_matrix, excess, height, active, count, Q)) == nothing
      @test length(Q) == 3

      # Test with default distances
      @test GraphsFlows.push_relabel(residual_graph, 1, 8, GraphsFlows.DefaultCapacity(residual_graph))[1] == 3

      # Test with capacity matrix
      @test GraphsFlows.push_relabel(residual_graph, 1, 8, capacity_matrix)[1] == 28
    end
    # Non regression test added for #448
    M448 = [0 1 0 0 1 1
            1 0 0 0 1 0
            0 0 0 1 0 0
            0 0 0 0 0 0
            1 0 1 0 0 1
            0 0 0 0 1 0]
    g448 = Graphs.DiGraph(M448)
    @test maximum_flow(g448, 1, 2, M448, algorithm=PushRelabelAlgorithm())[1] == 1

    # Non regression test for floating point error (issue #28 in LightGraphsFlows.jl)
    M28 = [0 0 1 1 1 0 0 0
           0 0 0 0 0 0 0 0
           0 0 0 0 0 1 1 1
           0 0 0 0 0 1 1 1
           0 0 0 0 0 1 1 1
           0 1 0 0 0 0 0 0
           0 1 0 0 0 0 0 0
           0 1 0 0 0 0 0 0]
    g28 = Graphs.DiGraph(M28)
    C28 = [0. 0. 0.1 0.1 0.1 0. 0. 0.
        0. 0. 0. 0. 0. 0. 0. 0.
        0. 0. 0. 0. 0. 1. 1. 1.
        0. 0. 0. 0. 0. 1. 1. 1.
        0. 0. 0. 0. 0. 1. 1. 1.
        0. 0. 0. 0. 0. 0. 0. 0.
        0. 0. 0. 0. 0. 0. 0. 0.
        0. 0. 0. 0. 0. 0. 0. 0.]
    @test maximum_flow(g28, 1, 2, C28, algorithm=PushRelabelAlgorithm())[1] == 0
end
