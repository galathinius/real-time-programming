-module(connection).

-export([start/0, stop/1]).

start() ->
    {Pid, Ref} = spawn_monitor(fun () -> tweets1() end),
    io:format("~p~p~n", ["started conn", Pid]),
    {ok, Pid}.

main() ->
    Url = "localhost",
    {ok, Conn} = shotgun:open(Url, 4000),
    {ok, Response} = shotgun:get(Conn, "/"),
    % {Body, _, _} = Response,
    io:format("~p~n", [Response]),
    shotgun:close(Conn).

% twitter_stream:tweets1().

tweets1() ->
    scaler:start_some(3),
    wait(10),
    % loop(),
    % ok.
    {ok, Conn} = shotgun:open("localhost", 4000),
    Options = #{async => true, async_mode => sse,
		handle_event =>
		    fun (_, _, Tre) -> router:route(Tre) end},
    {ok, Ref} = shotgun:get(Conn, "/tweets/2", #{},
			    Options),
    wait(1000),
    shotgun:close(Conn).

% Events = shotgun : events ( Conn ) , router : route ( Events ) ,
wait(Sec) -> receive  after 10 * Sec -> ok end.

loop() -> wait(4), loop().

stop(_State) -> ok.
