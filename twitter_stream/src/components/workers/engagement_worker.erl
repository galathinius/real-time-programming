-module(engagement_worker).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) -> {ok, #{}}.

handle_info({Tweet, Id}, State) ->
    one_event(Tweet, Id), {noreply, State}.

one_event(Event, Id) ->
    functions:thinking(),
    process_tweet(functions:get_tweet(Event), Id).

process_tweet(ok, _Id) -> ok;
process_tweet(panic, _Id) ->
    io:format("~p~p~n", ["paniking ", self()]),
    information:log_panic(),
    exit(undef);
process_tweet({tweet, Json}, Id) ->
    #{<<"message">> :=
	  #{<<"tweet">> :=
		#{<<"retweet_count">> := Retweets,
		  <<"favorite_count">> := Favourites,
		  <<"user">> := #{<<"followers_count">> := Followers}}}} =
	Json,
    Engagement = get_engagement(Retweets, Favourites,
				Followers),
    io:format("Engagement: ~p ~n", [Engagement]).

get_engagement(Retweets, Favourites, Followers) ->
    (Favourites + Retweets) / (Followers + 1).
