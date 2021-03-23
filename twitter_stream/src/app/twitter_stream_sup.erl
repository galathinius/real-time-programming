%%%-------------------------------------------------------------------
%% @doc twitter_stream top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(twitter_stream_sup).

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
    Information = #{id => information,
                    start => {information, start_link, []},
                    restart => permanent, shutdown => 2000, type => worker},
    EmotionalWorkerPool = #{id => emotional_pool,
                            start =>
                                {pool_sup,
                                 start_link,
                                 [event_publisher, "emotional_worker"]},
                            restart => permanent, shutdown => 2000,
                            type => supervisor},
    EngagementWorkerPool = #{id => engagement_pool,
                             start =>
                                 {pool_sup,
                                  start_link,
                                  [event_publisher, "engagement_worker"]},
                             restart => permanent, shutdown => 2000,
                             type => supervisor},
    ScalerPublisher = #{id => scaler_publisher,
                        start => {scaler_publisher, start_link, []},
                        restart => permanent, shutdown => 2000, type => worker},
    Stream1 = "/tweets/1",
    Conn1 = #{id => conn1,
              start => {connection, start, [Stream1]},
              restart => permanent, shutdown => 2000, type => worker},
    Stream2 = "/tweets/2",
    Conn2 = #{id => conn2,
              start => {connection, start, [Stream2]},
              restart => permanent, shutdown => 2000, type => worker},
    Publisher = #{id => publisher,
                  start => {event_publisher, start_link, []},
                  restart => permanent, shutdown => 2000, type => worker},
    % data
    DataSup = #{id => data_sup,
                start => {data_sup, start_link, []},
                restart => permanent, shutdown => 2000,
                type => supervisor},
    ChildSpecs = [Publisher,
                  Information,
                  ScalerPublisher,
                  EmotionalWorkerPool,
                  EngagementWorkerPool,
                  DataSup,
                  Conn1,
                  Conn2],
    {ok, {SupFlags, ChildSpecs}}.
