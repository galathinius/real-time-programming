-module(router).

-behaviour(gen_server).

-export([handle_cast/2, init/1, route/2, start_link/3]).

start_link(SelfName, Source, WorkerSoup) ->
    gen_server:start_link({local, SelfName},
                          ?MODULE,
                          [SelfName, Source, WorkerSoup],
                          []).

init([SelfName, Source, WorkerSoup]) ->
    io:format("~p~p~n", ["router", self()]),

    % Source:subscribe({?MODULE, route, [SelfName]}),
    {ok, #{current => 0, supervisor => WorkerSoup}}.

route(SelfName, Tweet) ->
    % router:route(worker_router, message)
    gen_server:cast(SelfName, {tweet, Tweet}),
    ok.

handle_cast({tweet, Tweet}, State) ->
    #{current := Current, supervisor := WorkerSoup} = State,
    send_to_worker(WorkerSoup, Current, Tweet),

    NewState = #{current => Current + 1,
                 supervisor => WorkerSoup},
    {noreply, NewState}.

send_to_worker(Soup, Current, Tweet) ->
    Pids = supervisor:which_children(Soup),
    Total = length(Pids),
    {_, Worker, _, _} = lists:nth(Current rem Total + 1,
                                  Pids),
    Worker ! Tweet.
