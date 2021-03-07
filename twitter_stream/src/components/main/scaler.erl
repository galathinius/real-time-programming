-module(scaler).

-behaviour(gen_server).

-export([handle_cast/2, handle_info/2, init/1,
	 start_link/0, start_some/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["scaler", self()]),
    erlang:start_timer(1000, self(), "timeout"),
    {ok, #{previous => 0}}.

start_some(Count) ->
    gen_server:cast(?MODULE, {hire, Count}).

handle_cast({hire, Count}, State) ->
    hire(Count), {noreply, State}.

handle_info({timeout, _, _}, State) ->
    #{previous := Previous} = State,
    #{events := Events, panics := Panics,
      actual_scores := Scores} =
	information:get_info(),
    WorkerPids = supervisor:which_children(emotional_soup),
    TotalWorkers = length(WorkerPids),
    Statistics = round(Events * 95 / 100 +
			 Previous * 5 / 100),
    ToHire = Statistics div 10 + 1 - TotalWorkers,
    io:format("in scaler: ~nPanics: ~p~nActual scores: "
	      "~p~nEvents: ~p~nWorkers: ~p ~nTo hire: "
	      "~p~n",
	      [Panics, Scores, Events, TotalWorkers, ToHire]),
    hire(ToHire),
    erlang:start_timer(1000, self(), "timeout"),
    {noreply, #{events => 0, previous => Statistics}}.

hire(0) -> ok;
hire(Count) when Count > 0 ->
    supervisor:start_child(emotional_soup, []),
    supervisor:start_child(engagement_soup, []),
    hire(Count - 1);
hire(Count) when Count < 0 ->
    % emotional workers
    [{_, EmotionalPid, _, _} | _EmotionalForgiven] =
	supervisor:which_children(emotional_soup),
    supervisor:terminate_child(emotional_soup,
			       EmotionalPid),
    % engagement workers
    [{_, EngagementPid, _, _} | _EngagementForgiven] =
	supervisor:which_children(engagement_soup),
    supervisor:terminate_child(engagement_soup,
			       EngagementPid),
    hire(Count + 1).