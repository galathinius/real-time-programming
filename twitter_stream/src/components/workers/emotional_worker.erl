-module(emotional_worker).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) -> {ok, #{}}.

handle_info({Tweet, Id1, Id2}, State) ->
    one_event(Tweet, Id1, Id2), {noreply, State}.

one_event(Event, Id1, Id2) ->
    functions:thinking(),
    process_json(functions:get_json(Event), Id1, Id2).

process_json(ok, _Id1, _Id2) -> ok;
process_json(panic, _Id1, _Id2) ->
    io:format("~p~p~n", ["paniking ", self()]),
    information:log_panic(),
    exit(undef);
process_json({tweet, Json}, Id1, Id2) ->
    Tweet = functions:get_tweet(Json),
    process_tweet(Tweet, Id1),
    process_tweet(functions:is_retweet(Tweet), Id2),
    process_tweet(functions:is_quote_tweet(Tweet), Id2).

process_tweet(false, _Id) -> ok;
process_tweet(Tweet, Id) ->
    #{<<"text">> := Text} = Tweet,
    Score = compute_text_score(Text),
    io:format("Score: ~p ~n", [Score]),
    aggregator:add_emotion(Score, Id).

compute_text_score(Text) ->
    NotBin = unicode:characters_to_list(Text, utf8),
    Low = string:lowercase(NotBin),
    Chunks = string:tokens(Low, " ,.?!;:/'"),
    Sum = lists:sum(lists:map(fun (Word) ->
				      emotional_score:get_score(Word)
			      end,
			      Chunks)),
    Value = Sum / length(Chunks),
    if Value /= 0 -> information:log_score();
       true -> ok
    end,
    Value.
