-module(twitter_stream).

-export([main/0, tweets1/0]).

main() ->
    Url = "localhost",
    {ok, Conn} = shotgun:open(Url, 4000),
    {ok, Response} = shotgun:get(Conn, "/"),
    % {Body, _, _} = Response,
    io:format("~p~n", [Response]),
    shotgun:close(Conn).

% twitter_stream:tweets1().

tweets1() ->
    % not tested
    {ok, Conn} = shotgun:open("localhost", 4000),
    Options = #{async => true, async_mode => sse},
    {ok, Ref} = shotgun:get(Conn, "/tweets/1", #{},
			    Options),
    wait(1),
    Events = shotgun:events(Conn),
    process_events(Events),
    % io:format("~p~n", [Events]),
    % shotgun:events(Conn).
    shotgun:close(Conn).

process_events(Events) ->
    [Head | Tail] = Events,
    one_event(Head),
    process_events(Tail).

one_event(Event) ->
    {_, _, Message} = Event,
    Text = shotgun:parse_event(Message),
    io:format("~p~n", [Text]).

wait(Sec) -> receive  after 10 * Sec -> ok end.
