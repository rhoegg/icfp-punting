import networkx
from functools import reduce
import operator
from graph_utils import combine_graphs


def path_edge_iter(path):
    for segment in zip(path[:-1], path[1:]):
        yield segment
        
def add_score(graph, edge, score):
    if 'score' in graph[edge[0]][edge[1]]:
        graph[edge[0]][edge[1]]['score'] += score
    else:
        graph[edge[0]][edge[1]]['score'] = score

def get_score(graph, edge):
    if 'score' in graph[edge[0]][edge[1]]:
        return graph[edge[0]][edge[1]]['score']
    else:
        return 0
        
def score_path(graph, mine, target, path=None):
    if path is None:
        path = networkx.shortest_path(graph, mine, target)
    for edge in path_edge_iter(path):
        add_score(graph, edge, (len(path)-1)**3)
        

def score_bridges(graph):
    for edge in graph.edges_iter():
        graph.remove_edge(*edge)
        try:
            p=networkx.shortest_path_length(graph, edge[0],edge[1])
        except networkx.NetworkXNoPath:
            p = 999*reduce(operator.mul,
                           map(lambda x: x-1,
                               graph.degree(edge).values()))
        graph.add_edge(*edge)
        p *= reduce(operator.mul,
                    map(lambda x: x-1,
                        graph.degree(edge).values()))
        add_score(graph, edge, p)
        
def score_segments(graph, source, target, path=None):
    if path is None:
        path = networkx.shortest_path(graph, source, target)
    for segment in path_edge_iter(path):
        graph.remove_edge(*segment)
        try:
            p = networkx.shortest_path_length(graph, source, target)
        except networkx.NetworkXNoPath:
            p = 9999999
        graph.add_edge(*segment)
        add_score(graph, segment, p)
        

def score_available_map(available, ours, source, target):
    the_world_now = combine_graphs(available, ours)
    score_bridges(the_world_now)
    path = networkx.shortest_path(the_world_now, source, target)
    score_segments(the_world_now, source, target, path=path)
    score_path(the_world_now, source, target, path=path)
    #Transfer those scores to available
    for edge in available.edges_iter():
        add_score(available, edge, get_score(the_world_now, edge))
    
            
    
    
    
    
        
