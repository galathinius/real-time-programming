-module(filter).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) -> {ok, #{}}.

handle_info({Event, Id1, Id2}, State) ->
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
