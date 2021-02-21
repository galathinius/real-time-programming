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
    Information = #{id => information,
		    start => {information, start_link, []},
		    restart => permanent, shutdown => 2000, type => worker,
		    modules => [information]},
    Soup = #{id => worker_soup,
	     start => {worker_soup, start_link, []},
	     restart => permanent, shutdown => 2000,
	     type => supervisor, modules => [worker_soup]},
    Router = #{id => router,
	       start => {router, start_link, []}, restart => permanent,
	       shutdown => 2000, type => worker, modules => [router]},
    Scaler = #{id => scaler,
	       start => {scaler, start_link, []}, restart => permanent,
	       shutdown => 2000, type => worker, modules => [scaler]},
    Stream1 = "/tweets/1",
    Conn1 = #{id => conn1,
	      start => {connection, start, [Stream1]},
	      restart => permanent, shutdown => 2000, type => worker,
	      modules => [connection]},
    Stream2 = "/tweets/2",
    Conn2 = #{id => conn2,
	      start => {connection, start, [Stream2]},
	      restart => permanent, shutdown => 2000, type => worker,
	      modules => [connection]},
    ChildSpecs = [Information, Soup, Router, Scaler, Conn1,
		  Conn2],
    {ok, {SupFlags, ChildSpecs}}.
