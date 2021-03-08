-module(filter).

-behaviour(gen_server).

-export([filter/2, handle_cast/2, init/1,
	 start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) -> io:format("~p~p~n", ["filter", self()]), ok.

filter(Event, Id) ->
    gen_server:cast(?MODULE, {event, Event, Id}), ok.

handle_cast({event, Event, Id}, State) ->
    send_to_aggregator(functions:get_tweet(Event), Id),
    {noreply, State}.

send_to_aggregator({tweet, Json}, Id) ->
    aggregator:add_tweet(Json, Id);
send_to_aggregator(_, _) -> ok.
