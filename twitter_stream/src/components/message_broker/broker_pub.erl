-module(broker_pub).

-behaviour(gen_server).

-export([handle_cast/2,
         init/1,
         send_message/2,
         start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE},
                          ?MODULE,
                          [],
                          []).

init([]) ->
    io:format("broker pub ~p~n", [self()]),
    {ok, Sock} = gen_tcp:connect("message-broker",
                                 3214,
                                 [{active, false}, {packet, raw}]),
    Topics = [<<"emotional">>,
              <<"engagement">>,
              <<"panic">>],
    gen_tcp:send(Sock, messages:publish_request(Topics)),
    {ok, #{sock => Sock}}.

send_message(Message, Topics) ->
    gen_server:cast(?MODULE, {events, Message, Topics}),
    ok.

handle_cast({events, Message, Topics}, State) ->
    #{sock := Sock} = State,

    gen_tcp:send(Sock,
                 messages:data_message(Message, Topics)),
    {noreply, State}.
