import networkx
#import strategies


def state_to_edges(state_dict):
    return [(key,y) for key, lst in map(lambda x: (int(x[0]), x[1]),
                                        state_dict.items())
            for y in map(int, lst) if key<y]
        
def initial_state_map(json_state):
    if 'initial' not in json_state:
        return 
    return networkx.Graph(state_to_edges(json_state['initial']))

def available_edges_map(json_state):
    if 'available' not in json_state:
        return
    return networkx.Graph(state_to_edges(json_state['available']))

def mine_locations(json_state):
    if 'mines' not in json_state:
        return
    return json_state['mines']

def n_players(json_state):
    if 'number_of_punters' in json_state:
        return int(json_state['number_of_punters'])

def my_id(json_state):
    if 'id' not in json_state:
        return
    return int(json_state['id'])

def my_rivers(json_state):
    id1 = my_id(json_state)
    if id1 is not None and id1 in json_state:
        return state_to_edges(json_state['id1'])

def label_edge(graph, edge, attr_name, attr_value):
    s1,s2 = edge
    graph[s1][s2][attr_name]=attr_value

def label_edges(graph, edges, attr_name, attr_value):
    for edge in edges:
        label_edge(graph, edge, attr_name, attr_value)

def label_vertex(graph, vertex, attr_name, attr_value):
    graph.node[vertex][attr_name] = attr_value

def label_verticies(graph, verticies, attr_name, attr_value):
    for vtx in verticies:
        label_vertex(graph, vtx, attr_name, attr_value)

def label_mines(graph, verticies):
    label_verticies(graph, verticies, 'is_mine', True)


def make_graph(json_state):
    #First, build the initial graph
    my_graph = initial_state_map(json_state)
    #Label the mines
    label_mines(my_graph, mine_locations(json_state))
    #Label the rivers owned by each player.  My rivers are
    #special, so we give them the attribute "ME"
    myid = my_id(json_state)
    player_ids = [k for k in json_state.keys() if k.isnumeric()]
    for player in player_ids:
        edges = state_to_edges(json_state[str(player)])
        if player == myid:
            label_edges(my_graph, edges, "ME", True)
        label_edges(my_graph, edges, "Player", player)
    return my_graph

def get_futures(json_state):
    futures = json_state["futures"]
    futures_with_int = []
    for future in futures:
        futures_with_int.append((int(future[0]),int(future[1])))
    return futures_with_int

    
                                
            
            

    
def default_json_to_edges(json_object):
    if "map" in json_object:
        jso = json_object['map']['rivers']
    elif 'rivers' in json_object:
        jso = json_object['rivers']
    else:
        return
    return ((x['source'],x['target']) for x in jso)
        
def create_graph(json_object):
    e = default_json_to_edges(json_object)
    if e is not None:
        return networkx.Graph(e)
