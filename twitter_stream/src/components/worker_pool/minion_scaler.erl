-module(minion_scaler).

-behaviour(gen_server).

-export([handle_cast/2,
         init/1,
         start_link/2,
         update/2]).

% module not tested

start_link(SelfName, WorkerSoup) ->
    gen_server:start_link({local, SelfName},
                          ?MODULE,
                          [SelfName, WorkerSoup],
                          []).

init([SelfName, WorkerSoup]) ->
    io:format("~p~p~n", ["minion scaler", self()]),

    scaler_publisher:subscribe({?MODULE,
                                update,
                                [SelfName]}),
    {ok, #{current => 0, supervisor => WorkerSoup}}.

update(SelfName, Tweet) ->
    gen_server:cast(SelfName, {hire, Tweet}),
    ok.

handle_cast({hire, Count}, State) ->
    #{supervisor := WorkerSoup} = State,
    hire(Count, WorkerSoup),
    {noreply, State}.

hire(0, _WorkerSoup) -> ok;
hire(Count, WorkerSoup) when Count > 0 ->
    supervisor:start_child(WorkerSoup, []),
    hire(Count - 1, WorkerSoup);
hire(Count, WorkerSoup) when Count < 0 ->
    [{_, EngagementPid, _, _} | _EngagementForgiven] =
        supervisor:which_children(WorkerSoup),
    supervisor:terminate_child(WorkerSoup, EngagementPid),
    hire(Count + 1, WorkerSoup).
