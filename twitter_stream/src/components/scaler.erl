-module(scaler).

-behaviour(gen_server).

-export([add_event/0, handle_cast/2, handle_info/2,
	 init/1, start_link/0, start_some/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["scaler", self()]),
    erlang:start_timer(1000, self(), "timeout"),
    {ok, #{events => 0}}.

add_event() -> gen_server:cast(?MODULE, {tweet}), ok.

start_some(Count) ->
    gen_server:cast(?MODULE, {hire, Count}).

handle_cast({tweet}, State) ->
    #{events := Events} = State,
    NewState = #{events => Events + 1},
    {noreply, NewState};
handle_cast({hire, Count}, State) ->
    hire(Count), {noreply, State}.

handle_info({timeout, _, _}, State) ->
    #{events := Events} = State,
    Pids = supervisor:which_children(worker_soup),
    Total = length(Pids),
    io:format("~p~p~p~n", ["in scaler ", Total, Events]),
    hire(Events div 100 + 1 - Total),
    erlang:start_timer(1000, self(), "timeout"),
    {noreply, State}.

hire(0) -> ok;
hire(Count) when n > 0 ->
    worker_soup:start_worker(), hire(Count - 1);
hire(Count) when n < 0 ->
    [{_, Pid, _, _} | _Forgiven] =
	supervisor:which_children(worker_soup),
    worker_soup:stop_worker(Pid),
    hire(Count + 1).

% hire_workers(0) -> ok;
% hire_workers(Count) ->
%     worker_soup:start_worker(), hire_workers(Count - 1).

% kill_one(Pid) -> worker_soup:stop_worker(Pid).

