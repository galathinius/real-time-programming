-module(connection).

-export([start/1, stop/1]).

start(Stream) ->
    {Pid, _Ref} = spawn_monitor(fun () -> tweets(Stream)
				end),
    io:format("~p~p~n", ["started conn", Pid]),
    {ok, Pid}.

tweets(Stream) ->
    scaler:start_some(10),
    {ok, Conn} = shotgun:open("localhost", 4000),
    Options = #{async => true, async_mode => sse,
		handle_event =>
		    fun (_, _, Tre) -> router:route(Tre) end},
    {ok, _Ref} = shotgun:get(Conn, Stream, #{}, Options),
    wait(10000),
    shotgun:close(Conn).

main() ->
    Url = "localhost",
    {ok, Conn} = shotgun:open(Url, 4000),
    {ok, Response} = shotgun:get(Conn, "/"),
    % {Body, _, _} = Response,
    io:format("~p~n", [Response]),
    shotgun:close(Conn).

wait(Units) -> receive  after 10 * Units -> ok end.

stop(_State) -> ok.
