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
    MaxRestart = 2,
    MaxTime = 100,
    SupFlags = #{strategy => one_for_all,
                 intensity => MaxRestart, period => MaxTime},
    %  main
    Information = #{id => information,
                    start => {information, start_link, []},
                    restart => permanent, shutdown => 2000, type => worker},
    EmotionalSoup = #{id => emotional_soup,
                      start =>
                          {worker_soup,
                           start_link,
                           [emotional_soup, emotional_worker]},
                      restart => permanent, shutdown => 2000,
                      type => supervisor},
    EngagementSoup = #{id => engagement_soup,
                       start =>
                           {worker_soup,
                            start_link,
                            [engagement_soup, engagement_worker]},
                       restart => permanent, shutdown => 2000,
                       type => supervisor},
    RouterEmotional = #{id => router_emotional,
                        start =>
                            {router,
                             start_link,
                             [emotion_router, emotional_soup]},
                        restart => permanent, shutdown => 2000, type => worker},
    RouterEngagement = #{id => router_engagement,
                         start =>
                             {router,
                              start_link,
                              [engagement_router, engagement_soup]},
                         restart => permanent, shutdown => 2000,
                         type => worker},
    ScalerEmotional = #{id => scaler_emotional,
                        start =>
                            {minion_scaler,
                             start_link,
                             [emotion_scaler, emotional_soup]},
                        restart => permanent, shutdown => 2000, type => worker},
    ScalerEngagement = #{id => scaler_engagement,
                         start =>
                             {minion_scaler,
                              start_link,
                              [engagement_scaler, engagement_soup]},
                         restart => permanent, shutdown => 2000,
                         type => worker},
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
                  EmotionalSoup,
                  EngagementSoup,
                  DataSup,
                  RouterEmotional,
                  RouterEngagement,
                  ScalerPublisher,
                  ScalerEmotional,
                  ScalerEngagement,
                  Conn1],
    {ok, {SupFlags, ChildSpecs}}.
