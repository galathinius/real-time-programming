-module(subscriber_distribution).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) -> {ok, #{}}.

handle_info({Data, Subscribers}, State) ->
    [router:route(subscriber_send_router,
                  {Data, Subscriber})
     || Subscriber <- Subscribers],
    {noreply, State}.
