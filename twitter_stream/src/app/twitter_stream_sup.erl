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
    SupFlags = #{strategy => one_for_one, intensity => 0,
		 period => 1},
    Worker = #{id => some_worker,
	       start => {worker, start_link, []}, restart => temporary,
	       shutdown => 2000, type => worker, modules => [worker]},
    Router = #{id => router,
	       start => {router, start_link, []}, restart => permanent,
	       shutdown => 2000, type => worker, modules => [router]},
    Conn = #{id => connection,
	     start => {connection, start, []}, restart => permanent,
	     shutdown => 2000, type => worker,
	     modules => [connection]},
    ChildSpecs = [Worker, Router, Conn],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

