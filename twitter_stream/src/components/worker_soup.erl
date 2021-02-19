%%%-------------------------------------------------------------------
%% @doc twitter_stream worker supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(worker_soup).

-behaviour(supervisor).

-export([start_link/0, start_worker/0, stop/0,
	 stop_worker/1]).

-export([init/1]).

-define(SERVER, ?MODULE).

start_link() ->
    supervisor:start_link({local, worker_soup}, ?MODULE,
			  []).

init([]) ->
    MaxRestart = 6,
    MaxTime = 3600,
    SupFlags = #{strategy => simple_one_for_one,
		 intensity => MaxRestart, period => MaxTime},
    ChildSpecs = [#{id => call,
		    start => {worker, start_link, []}, restart => permanent,
		    shutdown => 2000, type => worker}],
    {ok, {SupFlags, ChildSpecs}}.

% worker_soup:start_worker().
start_worker() ->
    supervisor:start_child(worker_soup, []).

stop_worker(Pid) ->
    supervisor:terminate_child(worker_soup, Pid).

stop() ->
    case whereis(worker_soup) of
      P when is_pid(P) -> exit(P, kill);
      _ -> ok
    end.
