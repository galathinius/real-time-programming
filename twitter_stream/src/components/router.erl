-module(router).

-behaviour(gen_server).

-export([handle_cast/2, init/1, route/1, start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) -> {ok, #{}}.

route(Tweets) ->
    gen_server:cast(?MODULE, {tweets, Tweets}), ok.

handle_cast({tweets, Tweets}, State) ->
    process_events(Tweets), {noreply, State}.

process_events([Event]) -> worker:work(Event);
process_events(Events) ->
    [Head | Tail] = Events,
    worker:work(Head),
    process_events(Tail).
