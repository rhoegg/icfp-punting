# Punting

## Registration info ##

Team ID: bcf56290-bef0-40d0-8812-4e4ced85789b

Team name: The Mikinators

Team members:
* Paul Dawson
* Clayton Flesher
* James Edward Gray II
* Isaac Hall
* Ryan Hoegg
* Ed Livemgood
* Caleb Nordlich
* Miki Rezentes

## Entry Description

Our solution is an Elixir implementation compiled into a binary package release.

Strategies are implemented as simple algorithms that either return a move or nil. If a strategy returns nil, the meta-strategy moves on to the next available strategy.
Strategies we implemented include:
* Bet on a future 1/3 of the distance of a punter's available moves, then connect it.
* Try to make long connections.
* Grab a random river.
* Try to connect a site along a mine path that you own to the nearest mine.
* Try to connect to a mine you own to the closest mine you don't own.
* Grab a river attached to the mine with the most available spokes.
* Grab a river attached to the mine with the least available spokes.
* Try to connect the source and target you bet on as a future.

We played these strategies in different hierarchy combinations against one another, and then chose the combination that scored the best.
