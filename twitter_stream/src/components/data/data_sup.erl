%%%-------------------------------------------------------------------
%% @doc twitter_stream data supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(data_sup).

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
    % children definitions
    Filter = #{id => filter,
	       start => {filter, start_link, []}, restart => permanent,
	       shutdown => 2000, type => worker},
    Aggregator = #{id => aggregator,
		   start => {aggregator, start_link, []},
		   restart => permanent, shutdown => 2000, type => worker},
    Transformer = #{id => transformer,
		    start => {information_transformer, start_link, []},
		    restart => permanent, shutdown => 2000, type => worker},
    Sink = #{id => sink, start => {sink, start_link, []},
	     restart => permanent, shutdown => 2000, type => worker},
    Database = #{id => database,
		 start => {database, start_link, []},
		 restart => permanent, shutdown => 2000, type => worker},
    % children to start
    ChildSpecs = [Filter, Aggregator, Transformer, Sink,
		  Database],
    {ok, {SupFlags, ChildSpecs}}.
