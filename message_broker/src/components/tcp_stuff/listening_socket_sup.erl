-module(listening_socket_sup).

-behaviour(supervisor).

-export([start_link/0, start_listening/1]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?MODULE}, ?MODULE, []).

init([]) ->
    io:format("~p~p~n", ["soup", self()]),
    MaxRestart = 6,
    MaxTime = 3600,
    SupFlags = #{strategy => simple_one_for_one,
                 intensity => MaxRestart, period => MaxTime},
    ChildSpecs = [#{id => call,
                    start => {listening_socket, start_link, []},
                    restart => temporary, shutdown => 2000,
                    type => worker}],
    {ok, {SupFlags, ChildSpecs}}.

start_listening(Param) ->
    supervisor:start_child(?MODULE, [Param]).
