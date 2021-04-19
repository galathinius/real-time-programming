%%%-------------------------------------------------------------------
%% @doc twitter_stream worker pool superior supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(pool_sup).

-behaviour(supervisor).

-export([start_link/3]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link(Source, WorkerName, NumWorkers) ->
    %modified for fixed num of workers
    supervisor:start_link({local,
                           list_to_atom(WorkerName ++ "_pool_sup")},
                          ?MODULE,
                          [Source, WorkerName, NumWorkers]).

init([Source, WorkerName, NumWorkers]) ->
    MaxRestart = 1,
    MaxTime = 1000,
    SupFlags = #{strategy => one_for_all,
                 intensity => MaxRestart, period => MaxTime},
    % employee names
    WorkerAtom = list_to_atom(WorkerName),
    WorkerSoup = list_to_atom(WorkerName ++ "_soup"),
    Router = list_to_atom(WorkerName ++ "_router"),
    Scaler = list_to_atom(WorkerName ++ "_scaler"),
    %  main
    Soup = #{id => WorkerSoup,
             start =>
                 {worker_soup, start_link, [WorkerSoup, WorkerAtom]},
             restart => permanent, shutdown => 2000,
             type => supervisor},
    PoolRouter = #{id => Router,
                   start =>
                       {router, start_link, [Router, Source, WorkerSoup]},
                   restart => permanent, shutdown => 2000, type => worker},
    PoolScaler = #{id => Scaler,
                   start =>
                       {minion_scaler,
                        start_link,
                        [Scaler, WorkerSoup, NumWorkers]},
                   restart => permanent, shutdown => 2000, type => worker},
    ChildSpecs = [Soup, PoolRouter, PoolScaler],
    {ok, {SupFlags, ChildSpecs}}.
