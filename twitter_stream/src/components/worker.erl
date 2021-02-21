-module(worker).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) ->
    io:format("~p~p~n", ["a worker ", self()]), {ok, #{}}.

handle_info(Tweet, State) ->
    one_event(Tweet), {noreply, State}.

one_event(Event) ->
    Text = shotgun:parse_event(Event),
    #{data := Data} = Text,
    Isjson = jsx:is_json(Data),
    if Isjson == true -> ok;
       % process_map(Data);
       true -> detect_panic(Data)
    end.

detect_panic(Map) ->
    % io:format("~p~p~n", ["one ", Map]),
    TheMap = unicode:characters_to_list(Map, utf8),
    % io:format("~p~p~n", ["two ", TheMap]),
    Index = string:str(TheMap, "panic"),
    if Index > 0 ->
	   io:format("~p~p~n", ["paniking ", self()]), exit(undef);
       % process_map(Data);
       true -> ok
    end.

    % #{<<"message">> := Message} = TheMap,

process_map(Amap) ->
    % io:format("~p~n", ["\ngot something\n"]),
    TheMap = jsx:decode(Amap),
    #{<<"message">> :=
	  #{<<"tweet">> := #{<<"text">> := Text}}} =
	TheMap,
    NotBin = unicode:characters_to_list(Text, utf8),
    Low = string:lowercase(NotBin),
    Chunks = string:tokens(Low, [$\s]).

    % io:format("~p~p~n", [self(), Chunks]).

wait(Sec) -> receive  after 100 * Sec -> ok end.
