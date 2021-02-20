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

%% sup_flags() = #{strategy => strategy(),         % optional
%%                 intensity => non_neg_integer(), % optional
%%                 period => pos_integer()}        % optional
%% child_spec() = #{id => child_id(),       % mandatory
%%                  start => mfargs(),      % mandatory
%%                  restart => restart(),   % optional
%%                  shutdown => shutdown(), % optional
%%                  type => worker(),       % optional
%%                  modules => modules()}   % optional
init([]) ->
    MaxRestart = 6,
    MaxTime = 3600,
    SupFlags = #{strategy => one_for_one,
		 intensity => MaxRestart, period => MaxTime},
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
    Conn = #{id => connection,
	     start => {connection, start, []}, restart => permanent,
	     shutdown => 2000, type => worker,
	     modules => [connection]},
    ChildSpecs = [Soup, Router, Scaler, Conn],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

