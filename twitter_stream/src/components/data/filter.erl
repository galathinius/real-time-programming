-module(filter).

-behaviour(gen_server).

-export([add_event/3, handle_cast/2, init/1,
	 start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["filter", self()]), {ok, #{}}.

add_event(Event, Id1, Id2) ->
    gen_server:cast(?MODULE, {event, Event, Id1, Id2}), ok.

handle_cast({event, Event, Id1, Id2}, State) ->
    process_json(functions:get_json(Event), Id1, Id2),
    {noreply, State}.

process_json({tweet, Json}, Id1, Id2) ->
    Tweet = functions:get_tweet(Json),
    send_to_aggregator(Tweet, Id1),
    send_to_aggregator(functions:is_retweet(Tweet), Id2),
    send_to_aggregator(functions:is_quote_tweet(Tweet),
		       Id2);
process_json(_, _, _) -> ok.

send_to_aggregator(false, _Id) -> ok;
send_to_aggregator(Tweet, Id) ->
    aggregator:add_tweet(Tweet, Id).
