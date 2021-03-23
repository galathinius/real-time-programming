-module(router).

-behaviour(gen_server).

-export([handle_cast/2, init/1, route/2, start_link/2]).

start_link(SelfName, WorkerSoup) ->
    gen_server:start_link({local, SelfName},
                          ?MODULE,
                          [SelfName, WorkerSoup],
                          []).

init([SelfName, WorkerSoup]) ->
    io:format("~p~p~n", ["router", self()]),

    event_publisher:subscribe({?MODULE, route, [SelfName]}),
    {ok, #{current => 0, supervisor => WorkerSoup}}.

route(SelfName, Tweet) ->
    gen_server:cast(SelfName, {tweet, Tweet}),
    ok.

handle_cast({tweet, {Tweet, Id1, Id2}}, State) ->
    #{current := Current, supervisor := WorkerSoup} = State,
    send_to_worker(WorkerSoup, Current, Tweet, Id1, Id2),

    NewState = #{current => Current + 1,
                 supervisor => WorkerSoup},
    {noreply, NewState}.

send_to_worker(Soup, Current, Tweet, Id1, Id2) ->
    Pids = supervisor:which_children(Soup),
    Total = length(Pids),
    {_, Worker, _, _} = lists:nth(Current rem Total + 1,
                                  Pids),
    Worker ! {Tweet, Id1, Id2}.
