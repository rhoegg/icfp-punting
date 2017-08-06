import sys
import networkx
import json
import strategies


def json_generator():
    for line in sys.stdin:
        yield json.loads(line.strip())

def json_to_edges(json_object):
    if "map" in json_object:
        jso = json_object['map']['rivers']
    elif 'rivers' in json_object:
        jso = json_object['rivers']
    else:
        return
    return ((x['source'],x['target']) for x in jso)
        
def create_graph(json_object):
    e = json_to_edges(json_object)
    if e is not None:
        return networkx.Graph(e)
    

    
if __name__ == '__main__':
    for js in json_generator():
        
              
