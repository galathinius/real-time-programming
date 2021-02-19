%%%-------------------------------------------------------------------
%% @doc twitter_stream top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(worker_soup).

-behaviour(supervisor).

-export([start_link/0, start_worker/3, stop/0,
	 stop_worker/1]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, worker_soup}, ?MODULE,
			  []).

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
    SupFlags = #{strategy => simple_one_for_one,
		 intensity => MaxRestart, period => MaxTime},
    ChildSpecs = [#{id => call,
		    start => {worker, start_link, []},
		    shutdown => brutal_kill}],
    {ok, {SupFlags, ChildSpecs}}.

%% internal functions

start_worker() ->
    % ChildSpec = {Name,
    % 	 {ppool_sup, start_link, [Name, Limit, MFA]}, permanent,
    % 	 10500, supervisor, [ppool_sup]},
    supervisor:start_child(worker_soup, ChildSpec).

stop() ->
    case whereis(worker_soup) of
      P when is_pid(P) -> exit(P, kill);
      _ -> ok
    end.
