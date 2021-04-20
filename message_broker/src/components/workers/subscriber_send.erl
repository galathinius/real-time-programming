-module(subscriber_send).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) -> {ok, #{}}.

handle_info({Data, [Subscriber]}, State) ->
    gen_tcp:send(Subscriber, Data),
    {noreply, State}.
