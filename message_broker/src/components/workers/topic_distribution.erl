-module(topic_distribution).

-behaviour(gen_server).

-export([handle_info/2, init/1, start_link/0]).

start_link() -> gen_server:start_link(?MODULE, [], []).

init([]) -> {ok, #{}}.

handle_info({Data, Topics}, State) ->
    io:format("topic_distribution ~p ~p~n", [Data, Topics]),
    [router:route(subscriber_distribution_router,
                  {Data, table:get_subs_of_topic(Topic)})
     || Topic <- Topics],
    {noreply, State}.
