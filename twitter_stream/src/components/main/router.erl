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
    information:log_event(),
    gen_server:cast(?MODULE, {tweet, Tweet}),
    ok.

handle_cast({tweet, Tweet}, State) ->
    #{current := Current} = State,
    Id = uuid:uuid1(),
    send_to_worker(emotional_soup, Current, Tweet, Id),
    send_to_worker(engagement_soup, Current, Tweet, Id),
    NewState = #{current => Current + 1},
    {noreply, NewState}.

send_to_worker(Soup, Current, Tweet, Id) ->
    Pids = supervisor:which_children(Soup),
    Total = length(Pids),
    {_, Worker, _, _} = lists:nth(Current rem Total + 1,
				  Pids),
    Worker ! {Tweet, Id}.
