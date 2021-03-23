-module(connection).

-export([start/1]).

start(Stream) ->
    {Pid, _Ref} = spawn_monitor(fun () -> tweets(Stream)
                                end),
    io:format("~p~p~n", ["started conn", Pid]),
    {ok, Pid}.

tweets(Stream) ->
    scaler_publisher:start_some(10),
    {ok, Conn} = shotgun:open("localhost", 4000),
    Options = #{async => true, async_mode => sse,
                handle_event =>
                    fun (_, _, Tre) -> event_publisher:publish(Tre) end},
    {ok, _Ref} = shotgun:get(Conn, Stream, #{}, Options),
    functions:wait(1000),
    shotgun:close(Conn).

main() ->
    Url = "localhost",
    {ok, Conn} = shotgun:open(Url, 4000),
    {ok, Response} = shotgun:get(Conn, "/"),
    % {Body, _, _} = Response,
    io:format("~p~n", [Response]),
    shotgun:close(Conn).
