-module(connection).

-export([start/0, stop/1]).

start() ->
    io:format("~p~n", ["started conn"]),
    {Pid, Ref} = spawn_monitor(fun () -> tweets1() end),
    {ok, Pid}.

loop() ->
    io:format("~p~n", ["still heree"]), wait(10), loop().

main() ->
    Url = "localhost",
    {ok, Conn} = shotgun:open(Url, 4000),
    {ok, Response} = shotgun:get(Conn, "/"),
    % {Body, _, _} = Response,
    io:format("~p~n", [Response]),
    shotgun:close(Conn).

% twitter_stream:tweets1().

tweets1() ->
    {ok, Conn} = shotgun:open("localhost", 4000),
    Options = #{async => true, async_mode => sse,
		handle_event =>
		    fun (_, _, Thre) -> router:route(Thre) end},
    {ok, Ref} = shotgun:get(Conn, "/tweets/1", #{},
			    Options),
    wait(1),
    % Events = shotgun:events(Conn),
    % router:route(Events),
    shotgun:close(Conn).

wait(Sec) -> receive  after 100 * Sec -> ok end.

stop(_State) -> ok.

% tweets_test() ->
%     {ok, Conn} = shotgun:open("localhost", 4000),
%     Options = #{async => true, async_mode => sse},
%     {ok, Ref} = shotgun:get(Conn, "/tweets/1", #{},
% 			    Options),
%     wait(1),
%     Events = shotgun:events(Conn),
%     process_events(Events),
%     shotgun:close(Conn).

% process_events(Events) ->
%     [Head | Tail] = Events,
%     one_event(Head),
%     process_events(Tail).

% one_event(Event) ->
%     {_, _, Message} = Event,
%     Text = shotgun:parse_event(Message),
%     #{data := Data} = Text,
%     Isjson = jsx:is_json(Data),
%     if Isjson == true -> process_map(Data);
%        true -> io:fwrite("")
%     end.

% process_map(Amap) ->
%     io:format("~p~n", ["\ngot something\n"]),
%     TheMap = jsx:decode(Amap),
%     #{<<"message">> :=
% 	  #{<<"tweet">> := #{<<"text">> := Text}}} =
% 	TheMap,
%     NotBin = unicode:characters_to_list(Text, utf8),
%     Low = string:lowercase(NotBin),
%     Chunks = string:tokens(Low, [$\s]),
%     io:format("~p~n", [Chunks]).

