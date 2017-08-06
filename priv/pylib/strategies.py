import networkx
import itertools as it
from functools import partial
from networkx.algorithms.connectivity import minimum_st_edge_cut
import json
from graph_utils import *
from scoring import score_available_map, get_score
import logging

DEBUG=True

def rank_segments(graph, source, target, path=None):
    if path is None:
        path=networkx.shortest_path(graph,source,target)
    L0 = len(path)-1
    path_growth = []
    segments = ((x,path[i+1]) for i,x in enumerate(path[:-1]))
    for segment in segments:
        #Remove the segment
        graph.remove_edge(*segment)
        #do stuff
        try:
            ptest = networkx.shortest_path_length(graph, source,target)
        except networkx.NetworkXNoPath:
            ptest = 999999
        path_growth.append((segment, ptest-L0))
        #add the segment back.  VERY IMPORTANT!!!!
        graph.add_edge(*segment)
    return path_growth


def compute_futures(graph, mines, n_players,
                    max_pts_to_consider=10,
                    min_degree=3,
                    bridge_dist_threshold=5,
                    bridge_num_threshold=3,
                    bridge_cut_threshold=2):
    deg = networkx.degree(graph)
    md = filter(lambda x: x[1]<min_degree,
                mine_degrees(deg, mines))
    sd = filter(lambda x: x in mines,
                filter(lambda x: x[1]<min_degree,
                       most_connected_points(deg, N=max_pts_to_consider)))
    #fbridges = []
    fsources = []
    ftargets = []
    for mine in md:
        #Compute the best future for each mine
        sorted_distances = sorted(mine_to_target_with_path(graph, mine, sd),
                                  key=lambda x:x[1], reverse=True)
        for (source, target), path in sorted_distances:
            if target in mines:
                continue
            segment_rank = rank_segments(graph, source, target, path)
            if len(filter(lambda x:x[-1]> bridge_dist_threshold,
                          segment_rank))<bridge_cut_threshold:
                #we will probably keep this one
                bridges = networkx.minimum_edge_cut(graph, source, target)
                if len(bridges) < bridge_cut_threshold:
                    continue
                    #fbridges+=bridges
                fsources.append(source)
                ftargets.append(target)
                break
    if len(fsources)==0 or ftargets==0:
        return None
    return list(map(list, zip(fsources, ftargets)))
    
    
    
def compute_future_old(graph, mines, n_players, min_degree = 3,
                       max_pts_to_consider=10, max_mines_to_consider=10,
                       bridge_dist_threshold=5, bridge_num_threshold=3,
                       bridge_cut_threshold=2):
    """Returns future source, target and bridge collection.  Only one of
    The bridges found must be captured.  Returns 3 Nones if no acceptable
    Future is found.

    Parameters:  graph:  a graph
                 mines:  The list of mines to consider
                 n_players:  The number of players in the game
                 min_degree: Minimum degree of source/target to be
                             considered as a potential future.  Lower
                             this number to be more risky.  Increase
                             this number to be more conservative.
                             Increasing too far will cause no paths to be
                             found.  Usually set between 2 and 5?
                             default=3
                 max_pts_to_consider:  Limits the list of final points to
                                       consider to this many of the most
                                       connected points.  Lower this number
                                       to conserve run-time.  Increase to
                                       consider more paths.  Default=10
                 max_mines to consider: Limits the list of mines for
                                        consideration to the N most
                                        connected. default=10
                 bridge_dist_threshold: Increase in shortest path length
                                        that cutting a segment will cause
                                        that segment to be called a
                                        potential bridge. default= 5
                 bridge_num_threshod: If more than n segments increase the
                                      the shortest path by more than
                                      bridge_dist_threshold, eliminate
                                      this path from consideration.
                                      default=3
                 bridge_cut_threshod: The threshold on the minimum number
                                      of cuts that disconnect source from
                                      receiver.  default=2
                                       
    """
    
    deg = networkx.degree(graph)
    #logging.debug("degrees")
    md = filter(lambda x: x[1]<min_degree,
                mine_degrees(deg, mines)[:max_mines_to_consider])
    #logging.debug("mines")
    sd = filter(lambda x: x in mines,
                filter(lambda x: x[1]<min_degree,
                       most_connected_points(deg, N=max_pts_to_consider)))
    #logging.debug("targets")
    sorted_distances=sorted(mines_to_target_with_path(graph, md, sd),
                            key=lambda x:x[1], reverse=True)
    #logging.debug("distances")
    #fbridges = None
    fsource = None
    ftarget = None
    for (source, target), path in sorted_distances:
        if target in mines:
            continue
        segment_rank = rank_segments(graph, source, target, path)
        if len(filter(lambda x: x[-1]>bridge_dist_threshold,
                      segment_rank))<bridge_cut_threshold:
                #we will probably keep this one.
            bridges = networkx.minimum_edge_cut(graph, source, target)
            if len(bridges) < bridge_cut_threshold:
                continue
                #fbridges = bridges
            fsource = source
            ftarget = target
            break
    if fsource is None or ftarget is None:
        return None
        
    return [[fsource, ftarget]]
    

def move_toward_future(our_graph, current_graph,
                       future_mine, future_site,
                       our_id):
    #Make combined graph of our stuff plus current state
    not_theirs = combine_graphs(our_graph, current_graph)
    #Make sure we still have a path to the future:
    try:
        p = networkx.shortest_path(not_theirs, future_mine, future_site)
    except networkx.NetworkXNoPath:
        #return json.dumps("ABORT FUTURE")
        return None
        
    segments_along_shortest_path = list(zip(p[:-1],p[1:]))
    #Get a bridge along the current shortest path
    new_bridges = networkx.minimum_edge_cut(not_theirs, future_mine,
                                            future_site)
    #Loop over those new bridges
    for bridge in new_bridges:
        logging.debug("found bridge "+str(bridge))
        logging.debug(str(segments_along_shortest_path))
        #If we do not own a bridge on the shortest path, get it
        if bridge in segments_along_shortest_path and bridge not in our_graph.edges_iter():
            return json.dumps({"claim":{"punter":our_id,
                                        "source":bridge[0],
                                        "target":bridge[1]}})
    
    
    #If we have made it here, then we don't have an emergency bridge to get
    
    #on our shortest path to get.
    #So grab the first segment along our shortest path
    for segment in segments_along_shortest_path:
        logging.debug("segment "+str(segment))
        if segment not in our_graph.edges_iter():
            return json.dumps({"claim":{"punter":our_id,
                                        "source":segment[0],
                                        "target":segment[1]}})
    #If we have made it here, then hopefully we have reached our future.
    return None


            



def future_scoring(available_map, our_graph, futures):
    for mine, target in futures:
        score_available_map(available_map, our_graph, mine, target)

def choose_highest_score(scored_map):
    max_score, max_edge = 0,None
    for edge in scored_map.edges_iter():
        score = get_score(scored_map, edge)
        if score > max_score:
            max_score = score
            max_edge = edge
    return max_edge
    
def future_score_move(available_map, our_graph, futures, my_id):
    future_scoring(available_map, our_graph, futures)
    max_edge = choose_highest_score(available_map)
    if max_edge:
        return json.dumps({"claim":{"punter":my_id,
                                     "source":max_edge[0],
                                     "target":max_edge[1]}})
    else:
        return None

        

