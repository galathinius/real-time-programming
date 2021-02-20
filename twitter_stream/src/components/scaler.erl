-module(scaler).

-behaviour(gen_server).

-export([handle_cast/2, init/1, scale/1, start_link/0,
	 start_some/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["scaler", self()]),
    {ok, #{pids => []}}.

start_some(Count) ->
    gen_server:cast(?MODULE, {hire, Count}).

scale(Tweets) ->
    gen_server:cast(?MODULE, {tweets, Tweets}), ok.

handle_cast({hire, Count}, State) ->
    hire_workers(Count), {noreply, State};
handle_cast({tweets, Tweets}, State) ->
    process_events(Tweets), {noreply, State}.

hire_workers(0) -> ok;
hire_workers(Count) ->
    worker_soup:start_worker(), hire_workers(Count - 1).

process_events([Event]) -> worker:work(Event);
process_events(Events) ->
    [Head | Tail] = Events,
    worker:work(Head),
    process_events(Tail).

kill_one(Pid) -> worker_soup:stop_worker(Pid).
