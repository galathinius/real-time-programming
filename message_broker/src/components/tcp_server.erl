-module(tcp_server).

-export([server/1, start/0, start/1]).

start() -> start(3214).

start(Port) ->
    spawn(?MODULE, server, [Port]),
    ok.

server(Port) ->
    io:format("started tcp ~p~n", [self()]),
    io:format("start server at port ~p~n", [Port]),
    {ok, ListenSocket} = gen_tcp:listen(Port,
                                        [binary, {active, true}]),
    [listening_socket_sup:start_listening(ListenSocket)
     || _Id <- lists:seq(1, 5)],
    timer:sleep(infinity),
    ok.
