import networkx

def combine_graphs(graph1, graph2):
    G = networkx.Graph()
    G.add_edges_from(graph1.edges_iter())
    G.add_edges_from(graph2.edges_iter())
    return G
    
def mine_degrees(graph_degree, mines):
    return sorted([(k,v) for k,v in graph_degree if k in mines],
                  key = lambda x: x[1],
                  reverse=True)
    
def mine_to_mine_distance(graph, mines):
    #Returns a dictionary key'd by (m1,m2).
    #values are (shortest distance, path)
    pd = partial(networkx.algorithms.shortest_path,
                 graph)
    return {x[0]:(len(x[1]),x[1])
            for x in map(lambda x:(x, pd(*x)),
                         it.combinations(mines,2))}
    
def most_connected_points(graph_degree, N=10):
    return sorted([(k,v) for k, v in graph_degree.items()],
                  key=lambda x:x[1], reverse=True)[:10]


def connected_graphs(graph):
    return list(networkx.algorithms.connected_component_subgraphs(graph))


def mine_to_target_distances(graph, mine, sorted_targets):
    #sorted_mines and targets we WANT to be sorted by connectivity
    sources_targets = ((mine ,y[0]) for y in sorted_targets)
    dmap = map(lambda x:(x,
                         networkx.shortest_path_length(graph, *x)),
               sources_targets)
    return list(dmap)


def mine_to_target_with_path(graph, mine, sorted_targets):
    sources_targets = ((mine,y[0]) for y in sorted_targets)
    dmap = map(lambda x:(x,networkx.shortest_path(graph, *x)),
               sources_targets)
    return list(dmap)


