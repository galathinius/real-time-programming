-module(router).

-behaviour(gen_server).

-export([handle_cast/2, init/1, route/1, start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["router", self()]),
    {ok, #{current => 0}}.

route(Tweet) ->
    scaler:add_event(),
    gen_server:cast(?MODULE, {tweet, Tweet}),
    ok.

handle_cast({tweet, Tweet}, State) ->
    Pids = supervisor:which_children(worker_soup),
    #{current := Current} = State,
    Total = length(Pids),
    {_, Worker, _, _} = lists:nth(Current rem Total + 1,
				  Pids),
    Worker ! Tweet,
    NewState = #{current => Current + 1},
    {noreply, NewState}.
