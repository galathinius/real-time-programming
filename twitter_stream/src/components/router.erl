-module(router).

-behaviour(gen_server).

-export([handle_cast/2, init/1, route/1, start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    {ok, Pid1} = worker_soup:start_worker(),
    {ok, Pid2} = worker_soup:start_worker(),
    {ok, Pid3} = worker_soup:start_worker(),
    {ok, #{pids => [Pid1, Pid2, Pid3]}}.

route(Tweet) ->
    gen_server:cast(?MODULE, {tweet, Tweet}), ok.

handle_cast({tweet, Tweet}, State) ->
    #{pids := Pids} = State,
    [Head | Tail] = Pids,
    Head ! Tweet,
    NewState = {ok, #{pids => [Tail ++ Head]}},
    {noreply, NewState}.

process_events([Event]) -> worker:work(Event);
process_events(Events) ->
    [Head | Tail] = Events,
    worker:work(Head),
    process_events(Tail).
