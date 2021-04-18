-module(tcp_server).

-export([server/1, start_link/0, start_link/1]).

start_link() -> start_link(3214).

start_link(Port) ->
    {Pid, _Ref} = spawn_monitor(fun () -> server(Port) end),
    io:format("started server ~p~n", [self()]),
    {ok, Pid}.

server(Port) ->
    io:format("start server at port ~p~n", [Port]),
    {ok, ListenSocket} = gen_tcp:listen(Port,
                                        [binary,
                                         {active, true},
                                         {reuseaddr, true}]),
    [listening_socket_sup:start_listening(ListenSocket)
     || _Id <- lists:seq(1, 5)],
    timer:sleep(infinity),
    ok.
