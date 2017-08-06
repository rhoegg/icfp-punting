#import process_jsons
import json
import strat_wrap


funcmap = {"one_bet":strat_wrap.one_bet,
           "multi_bet":strat_wrap.one_bet,
           "future_one_move":strat_wrap.move_one_future,
           "futures_move":strat_wrap.move_scored_map
}


def unpack(stuff):
    stuff_i_heard = json.loads(stuff)
    strategy = stuff_i_heard['strategy']
    tag = stuff_i_heard['tag']
    kwargs = stuff_i_heard['kwargs']
    function = stuff_i_heard['function']
    game = stuff_i_heard['game']
    state = stuff_i_heard['state']
    comment = stuff_i_heard['comment']
    
    
    return tag, strategy, function, kwargs, game, state, comment

    
def pack(tag, bets=None, move=None, state=None):
    d = {'tag':tag}
    if bets is not None:
        d['bets']=bets
    if move is not None:
        d['move']=move
    if state is not None:
        d['state']=state
    return json.dumps(d)


def process_line(stuff):
    tag, strtg, func, kwargs, gm, state, cmmt=unpack(stuff)
    res = funcmap[func](gm, **kwargs)
    if "bet" in func:
        return pack(tag, bets=res)
    else:
        return pack(tag, move=res)
        

if __name__ == '__main__':
    line = input()

    while line:
        reply = process_line(line)
        print(reply)
        line = input()
        
