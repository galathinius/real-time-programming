-module(worker).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) ->
    io:format("~p~p~n", ["a worker ", self()]), {ok, #{}}.

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
	   io:format("~p~p~n", ["paniking ", self()]), exit(undef);
       true -> ok
    end.

process_map(Map) ->
    Json = jsx:decode(Map),
    #{<<"message">> :=
	  #{<<"tweet">> := #{<<"text">> := Text}}} =
	Json,
    process_tweet(Text).

process_tweet(Text) ->
    NotBin = unicode:characters_to_list(Text, utf8),
    Low = string:lowercase(NotBin),
    Chunks = string:tokens(Low, " ,.?!;:/'"),
    Sum = lists:sum(lists:map(fun (Word) ->
				      emotional_score:get_score(Word)
			      end,
			      Chunks)),
    Value = Sum / length(Chunks).

    % io:format("~p : ~p~n", [NotBin, Value]).

thinking() ->
    Ra = rand:uniform(),
    Int = round(Ra * 100),
    wait(Int),
    ok.

wait(Unit) -> receive  after 10 * Unit -> ok end.
