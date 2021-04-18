%%%-------------------------------------------------------------------
%% @doc message_broker top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(message_broker_sup).

-behaviour(supervisor).

-export([start_link/0]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

init([]) ->
    MaxRestart = 1,
    MaxTime = 1000,
    SupFlags = #{strategy => one_for_all,
                 intensity => MaxRestart, period => MaxTime},
    %  main
    Table = #{id => table, start => {table, start_link, []},
              restart => permanent, shutdown => 2000, type => worker},
    TcpServer = #{id => server,
                  start => {tcp_server, start_link, []},
                  restart => permanent, shutdown => 2000, type => worker},
    TcpListenersSup = #{id => listeners_sup,
                        start => {listening_socket_sup, start_link, []},
                        restart => permanent, shutdown => 2000,
                        type => supervisor},
    ChildSpecs = [Table, TcpListenersSup, TcpServer],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

