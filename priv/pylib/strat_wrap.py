import strategies
import process_jsons
import logging

def one_bet(game, **kwargs):
    graph = process_jsons.initial_state_map(game)
    n_players = process_jsons.n_players(game)
    mines = process_jsons.mine_locations(game)
    return strategies.compute_future_old(graph, mines, n_players, **kwargs)

def multi_bet(game, **kwargs):
    graph = process_jsons.initial_state_map(game)
    n_players = process_jsons.n_players(game)
    mines = process_jsons.mine_locations(game)
    return strategies.compute_futures(graph, mines, n_players, **kwargs)

def move_one_future(game, **kwargs):
    our_graph = process_jsons.my_rivers(game)
    current_graph = process_jsons.available_edges_map(game)
    future_mine=process_jsons.get_futures(game)[0][0]
    future_site=process_jsons.get_futures(game)[0][1]
    our_id=process_jsons.my_id(game)
    return strategies.move_toward_future(our_graph, current_graph,
                                         future_mine,future_site, our_id,
                                         **kwargs)

def move_scored_map(game, **kwargs):
    our_graph = process_jsons.my_rivers(game)
    available_map = process_jsons.available_edges_map(game)
    futures = process_jsons.get_futures(game)
    my_id = process_jsons.my_id(game)
    return strategies.future_score_move(available_map, our_graph,
                                        futures, my_id)


    
