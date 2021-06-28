-module(minion_scaler).

-behaviour(gen_server).

-export([add_event/1,
         handle_cast/2,
         handle_info/2,
         init/1,
         start_link/3]).


start_link(SelfName, WorkerSoup, NumWorkers) ->
    gen_server:start_link({local, SelfName},
                          ?MODULE,
                          [SelfName, WorkerSoup, NumWorkers],
                          []).





init([_SelfName, WorkerSoup, NumWorkers]) ->
    % io:format("~p~p~n", ["minion scaler", self()]),
    % modified for fixed num of workers
    erlang:start_timer(1000, self(), "timeout"),
    hire(NumWorkers, WorkerSoup),

    {ok, #{events => 0, supervisor => WorkerSoup}}.

update(SelfName, Tweet) ->
    gen_server:cast(SelfName, {hire, Tweet}),
    ok.

add_event(SelfName) ->
    gen_server:cast(SelfName, {event}),
    ok.

handle_cast({hire, Count}, State) ->
    #{supervisor := WorkerSoup} = State,
    hire(Count, WorkerSoup),
    {noreply, State};
handle_cast({event}, State) ->
    #{supervisor := WorkerSoup, events := Events} = State,
    NewState = #{events => Events + 1, supervisor => WorkerSoup},
    {noreply, NewState}.

handle_info({timeout, _, _}, State) ->
    #{supervisor := WorkerSoup, events := Events} = State,
    Workers = supervisor:which_children(WorkerSoup),
    NumberWorkers = length(Workers),
    ToHire = Events div 10 - NumberWorkers + 5,
    io:format("in scaler: ~n~nEvents: ~p~nWorkers: ~p ~nTo hire: ~p~n",
              [ Events, NumberWorkers, ToHire]),
    hire(ToHire, WorkerSoup),
    erlang:start_timer(1000, self(), "timeout"),
    NewState = #{events => 0, supervisor => WorkerSoup},
    {noreply, NewState}.

hire(0, _WorkerSoup) -> ok;
hire(Count, WorkerSoup) when Count > 0 ->
    supervisor:start_child(WorkerSoup, []),
    hire(Count - 1, WorkerSoup);
hire(Count, WorkerSoup) when Count < 0 ->
    [{_, EngagementPid, _, _} | _EngagementForgiven] =
        supervisor:which_children(WorkerSoup),
    supervisor:terminate_child(WorkerSoup, EngagementPid),
    hire(Count + 1, WorkerSoup).
