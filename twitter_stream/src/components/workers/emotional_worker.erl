-module(emotional_worker).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) -> {ok, #{}}.

handle_info(Tweet, State) ->
    one_event(Tweet), {noreply, State}.

one_event(Event) ->
    functions:thinking(),
    process_tweet(functions:get_tweet(Event)).

process_tweet(ok) -> ok;
process_tweet(panic) ->
    io:format("~p~p~n", ["paniking ", self()]),
    information:log_panic(),
    exit(undef);
process_tweet({tweet, Json}) ->
    #{<<"message">> :=
	  #{<<"tweet">> := #{<<"text">> := Text}}} =
	Json,
    compute_text_score(Text).

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
    io:format("Score: ~p~n", [Value]).
