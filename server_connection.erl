-module(server_connection).

-export([start_s/0]).

start_s() ->
    inets:start(),
    Url = "http://localhost:4000",
    % AuthHeader = {"Authorization", "Bearer abc123"},
    {ok, {{Version, 200, ReasonPhrase}, Headers, Body}} =
	httpc:request(get, {Url, []}, [], []),
    io:format("~s", [Body]).
