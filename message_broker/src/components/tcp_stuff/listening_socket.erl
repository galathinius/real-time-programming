-module(listening_socket).

-export([start_link/1]).

start_link(ListenSock) ->
    {Pid, _Ref} = spawn_monitor(fun () -> accept(ListenSock)
                                end),
    io:format("~p~p~n", ["started conn", Pid]),
    {ok, Pid}.

accept(ListenSocket) ->
    io:format("Socket #~p wait for client~n", [self()]),
    {ok, _Socket} = gen_tcp:accept(ListenSocket),
    io:format("Socket #~p, session started~n", [self()]),
    handle_connection(ListenSocket).

handle_connection(ListenSocket) ->
    receive
        {tcp, Socket, Msg} ->
            io:format("Socket #~p got message: ~p~n",
                      [self(), Msg]),
            receiving:process_message(messages:deserialize(Msg),
                                      ListenSocket,
                                      Socket);
        {tcp_closed, _Socket} ->
            io:format("Socket #~p, session closed ~n", [self()]),
            accept(ListenSocket)
    end.
