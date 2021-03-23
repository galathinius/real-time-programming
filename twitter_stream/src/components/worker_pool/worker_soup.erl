%%%-------------------------------------------------------------------
%% @doc twitter_stream worker supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(worker_soup).

-behaviour(supervisor).

-export([start_link/2]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link(SelfName, WorkerName) ->
    supervisor:start_link({local, SelfName},
                          ?MODULE,
                          [WorkerName]).

init([Worker]) ->
    io:format("~p~p~n", ["soup", self()]),
    MaxRestart = 6,
    MaxTime = 3600,
    SupFlags = #{strategy => simple_one_for_one,
                 intensity => MaxRestart, period => MaxTime},
    ChildSpecs = [#{id => call,
                    start => {Worker, start_link, []}, restart => permanent,
                    shutdown => 2000, type => worker}],
    {ok, {SupFlags, ChildSpecs}}.
