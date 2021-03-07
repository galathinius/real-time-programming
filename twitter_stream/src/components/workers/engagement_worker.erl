-module(engagement_worker).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) -> {ok, #{}}.

handle_info(Tweet, State) ->
    one_event(Tweet), {noreply, State}.

one_event(Event) ->
    thinking(),
    Text = shotgun:parse_event(Event),
    #{data := Data} = Text,
    Isjson = jsx:is_json(Data),
    if Isjson == true -> process_map(Data);
       true -> detect_panic(Data)
    end.

detect_panic(Map) ->
    TheMap = unicode:characters_to_list(Map, utf8),
    Index = string:str(TheMap, "panic"),
    if Index > 0 ->
	   io:format("~p~p~n", ["paniking ", self()]),
	   information:log_panic(),
	   exit(undef);
       true -> ok
    end.

process_map(Map) ->
    Json = jsx:decode(Map),
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

thinking() ->
    Ra = rand:uniform(),
    Int = round(Ra * 100),
    wait(Int),
    ok.

wait(Unit) -> receive  after 10 * Unit -> ok end.
