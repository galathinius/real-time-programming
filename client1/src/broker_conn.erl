-module(broker_conn).

-export([accept/0, handle_connection/1, start_link/0]).

start_link() ->
    {Pid, _Ref} = spawn_monitor(fun () -> accept() end),
    {ok, Pid}.

accept() ->
    Url = "message-broker",
    Port = 3214,

    {ok, Sock} = gen_tcp:connect(Url,
                                 Port,
                                 [{active, true}, {packet, raw}]),
    io:format("Socket #~p, session started~n", [self()]),
    gen_tcp:send(Sock,
                 messages:subscribe_request([<<"panic">>])),
    handle_connection(Sock).

handle_connection(ListenSocket) ->
    receive
        {tcp, Socket, Msg} ->
            io:format("got message: ~n~p~n", [Msg]),
            handle_connection(ListenSocket);
        {tcp_closed, _Socket} ->
            io:format("Socket #~p, session closed ~n", [self()]),
            accept()
    end.
