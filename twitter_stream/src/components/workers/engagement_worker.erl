-module(engagement_worker).

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
	  #{<<"tweet">> :=
		#{<<"retweet_count">> := Retweets,
		  <<"favorite_count">> := Favourites,
		  <<"user">> := #{<<"followers_count">> := Followers}}}} =
	Json,
    get_engagement(Retweets, Favourites, Followers).

get_engagement(Retweets, Favourites, Followers) ->
    Engagement = (Favourites + Retweets) / (Followers + 1),
    io:format("Engagement: ~p~n  ~p ~p ~p~n",
	      [Engagement, Retweets, Favourites, Followers]).
