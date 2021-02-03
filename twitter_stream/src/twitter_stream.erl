-module(twitter_stream).

-export([main/0, tweets1/0]).

main() ->
    Url = "localhost",
    {ok, Conn} = shotgun:open(Url, 4000),
    {ok, Response} = shotgun:get(Conn, "/"),
    % {Body, _, _} = Response,
    io:format("~p~n", [Response]),
    shotgun:close(Conn).

tweets1() ->
    % not tested
    {ok, Conn} = shotgun:open("locahost", 4000),
    Options = #{async => true, async_mode => sse},
    {ok, Ref} = shotgun:get(Conn, "/tweets/1", #{},
			    Options),
    Events = shotgun:events(Conn),
    shotgun:events(Conn).
