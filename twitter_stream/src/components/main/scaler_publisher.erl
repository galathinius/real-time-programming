-module(scaler_publisher).

-behaviour(gen_server).

-export([handle_cast/2,
         handle_info/2,
         init/1,
         start_link/0,
         start_some/1,
         subscribe/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE},
                          ?MODULE,
                          [],
                          []).

init([]) ->
    io:format("~p~p~n", ["scaler", self()]),
    erlang:start_timer(1000, self(), "timeout"),
    {ok, #{previous => 0, subscribers => []}}.

start_some(Count) ->
    gen_server:cast(?MODULE, {hire, Count}).

subscribe(Client) ->
    gen_server:cast(?MODULE, {sub, Client}),
    ok.

handle_cast({hire, Count}, State) ->
    #{subscribers := Subs} = State,
    functions:send_to_subscribers(Subs, Count),
    {noreply, State};
handle_cast({sub, Client}, State) ->
    #{subscribers := Subs, previous := Previous} = State,
    NewState = #{subscribers => Subs ++ [Client],
                 previous => Previous},
    {noreply, NewState}.

handle_info({timeout, _, _}, State) ->
    % getting info for stats
    #{previous := Previous, subscribers := Subs} = State,
    #{events := Events, panics := Panics,
      actual_scores := Scores} =
        information:get_info(),
    % calculating stats
    WorkerPids = supervisor:which_children(emotional_soup),
    TotalWorkers = length(WorkerPids),
    Statistics = round(Events * 95 / 100 +
                           Previous * 5 / 100),
    ToHire = Statistics div 10 + 1 - TotalWorkers,

    % posting stats in console
    io:format("in scaler: ~nPanics: ~p~nActual scores: "
              "~p~nEvents: ~p~nWorkers: ~p ~nTo hire: "
              "~p~n",
              [Panics, Scores, Events, TotalWorkers, ToHire]),
    % sending number to hire to minions
    functions:send_to_subscribers(Subs, ToHire),

    % restarting timer
    erlang:start_timer(1000, self(), "timeout"),
    {noreply,
     #{previous => Statistics, subscribers => Subs}}.
