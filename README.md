# Punting

## Registration info ##

Team ID: bcf56290-bef0-40d0-8812-4e4ced85789b

Team name: The Mikinators

Team members:
* Paul Dawson
* Clayton Flesher
* James Edward Gray II
* Isaac Hall
* Ed Livemgood
* Caleb Nordlich
* Miki Rezentes
* Ryan Hoegg

## Entry Description

Our solution is an Elixir implementation compiled into a binary package release.

We extracted strategies out as modules, so we can play them against one another online. Currently, our default strategy is...

[IMPORTANT! In order to return to this page later use the following link:](http://punter.inf.ed.ac.uk:9000/update/?token=bcf56290-bef0-40d0-8812-4e4ced85789b)

## Strategies
Composable strategies in lib/punting/strategy
Futures only - Well-connected point to a well-connected mine and try to connect them.

## Convenience bash loops, for running games ##
### loop until you connect ###
```bash
while true ; do
  mix run ./bin/compete.exs -i 10 -m gothenburg-sparse.json
  sleep 1
done
```

## fill in the last empty slot, to free up games ##
```bash
for ICFP_PORT in {9031..9040} ; do # or whatever
  MIX_ENV=prod ICFP_ONLINE=1  mix run --no-halt &
done
```

