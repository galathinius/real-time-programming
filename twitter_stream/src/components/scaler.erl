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
    {ok, #{events => 0, previous => 0}}.

add_event() -> gen_server:cast(?MODULE, {tweet}), ok.

start_some(Count) ->
    gen_server:cast(?MODULE, {hire, Count}).

handle_cast({tweet}, State) ->
    #{events := Events, previous := Previous} = State,
    NewState = #{events => Events + 1,
		 previous => Previous},
    {noreply, NewState};
handle_cast({hire, Count}, State) ->
    hire(Count), {noreply, State}.

handle_info({timeout, _, _}, State) ->
    #{events := Events, previous := Previous} = State,
    WorkerPids = supervisor:which_children(worker_soup),
    TotalWorkers = length(WorkerPids),
    io:format("~p~p ~p~n",
	      ["in scaler ", TotalWorkers, Events]),
    Statistics = round(Events * 95 / 100 +
			 Previous * 5 / 100),
    ToHire = Statistics div 10 + 1 - TotalWorkers,
    hire(ToHire),
    erlang:start_timer(1000, self(), "timeout"),
    {noreply, #{events => 0, previous => Statistics}}.

hire(0) -> ok;
hire(Count) when Count > 0 ->
    worker_soup:start_worker(), hire(Count - 1);
hire(Count) when Count < 0 ->
    [{_, Pid, _, _} | _Forgiven] =
	supervisor:which_children(worker_soup),
    worker_soup:stop_worker(Pid),
    hire(Count + 1).
