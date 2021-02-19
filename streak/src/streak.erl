-module(streak).

-export([main/0, tweets1/0]).

main() ->
    Url = "localhost",
    {ok, Conn} = shotgun:open(Url, 4000),
    {ok, Response} = shotgun:get(Conn, "/"),
    % {Body, _, _} = Response,
    io:format("~p~n", [Response]),
    shotgun:close(Conn).

% streak:tweets1().

tweets1() ->
    {ok, Conn} = shotgun:open("localhost", 4000),
    Options = #{async => true, async_mode => sse,
		handle_event =>
		    fun (One, Two, Thre) -> one_event(Thre) end},
    {ok, Ref} = shotgun:get(Conn, "/tweets/1", #{},
			    Options),
    wait(1),
    % Events = shotgun:events(Conn),
    % process_events(Events),
    shotgun:close(Conn).

test(One, Two, Thre) ->
    io:format("~p~p~p~n", [One, Two, Thre]).

process_events([Event]) -> one_event(Event);
process_events(Events) ->
    [Head | Tail] = Events,
    one_event(Head),
    process_events(Tail).

one_event(Event) ->
    % io:format("~p~n", [Event]).
    % {_, _, Message} = Event,
    Text = shotgun:parse_event(Event),
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

wait(Sec) -> receive  after 100 * Sec -> ok end.
