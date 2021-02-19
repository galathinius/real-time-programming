-module(worker).

-behaviour(gen_server).

-export([handle_cast/2, init/1, start_link/0, work/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) -> {ok, #{}}.

work(Tweet) ->
    gen_server:cast(?MODULE, {tweet, Tweet}), ok.

handle_cast({tweet, Tweet}, State) ->
    one_event(Tweet), {noreply, State}.

one_event(Event) ->
    {_, _, Message} = Event,
    Text = shotgun:parse_event(Message),
    #{data := Data} = Text,
    Isjson = jsx:is_json(Data),
    if Isjson == true -> process_map(Data);
       true -> io:fwrite("")
    end.

process_map(Amap) ->
    io:format("~p~n", ["\ngot something\n"]),
    TheMap = jsx:decode(Amap),
    #{<<"message">> :=
	  #{<<"tweet">> := #{<<"text">> := Text}}} =
	TheMap,
    NotBin = unicode:characters_to_list(Text, utf8),
    Low = string:lowercase(NotBin),
    Chunks = string:tokens(Low, [$\s]),
    io:format("~p~n", [Chunks]).

loop() ->
    io:format("~p~n", ["still heree"]), wait(10), loop().

wait(Sec) -> receive  after 100 * Sec -> ok end.

stop(_State) -> ok.
