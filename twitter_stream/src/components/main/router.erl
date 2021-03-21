-module(router).

-behaviour(gen_server).

-export([handle_cast/2, init/1, route/1, start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["router", self()]),
    publisher:subscribe({?MODULE, route}),
    {ok, #{current => 0}}.

route(Tweet) ->
    gen_server:cast(?MODULE, {tweet, Tweet}), ok.

handle_cast({tweet, {Tweet, Id1, Id2}}, State) ->
    #{current := Current} = State,
    send_to_worker(emotional_soup, Current, Tweet, Id1,
		   Id2),
    send_to_worker(engagement_soup, Current, Tweet, Id1,
		   Id2),
    NewState = #{current => Current + 1},
    {noreply, NewState}.

send_to_worker(Soup, Current, Tweet, Id1, Id2) ->
    Pids = supervisor:which_children(Soup),
    Total = length(Pids),
    {_, Worker, _, _} = lists:nth(Current rem Total + 1,
				  Pids),
    Worker ! {Tweet, Id1, Id2}.
