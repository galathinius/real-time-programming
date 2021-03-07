-module(filter).

-behaviour(gen_server).

-export([filter/1, handle_cast/2, init/1,
	 start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) -> io:format("~p~p~n", ["filter", self()]), ok.

filter(Event) ->
    gen_server:cast(?MODULE, {event, Event}), ok.

handle_cast({event, Event}, State) ->
    send_to_aggregator(functions:get_tweet(Event)),
    {noreply, State}.

send_to_aggregator({tweet, Json}) ->
    aggregator:get(Json);
send_to_aggregator(_) -> ok.
