-module(event_publisher).

-behaviour(gen_server).

-export([handle_cast/2,
         init/1,
         publish/1,
         start_link/0,
         subscribe/1]).

start_link() ->
    gen_server:start_link({local, ?MODULE},
                          ?MODULE,
                          [],
                          []).

init([]) ->
    % io:format("~p~p~n", ["publisher", self()]),
    {ok, #{subscribers => []}}.

publish(Event) ->
    gen_server:cast(?MODULE, {pub, Event}),
    ok.

subscribe(Client) ->
    gen_server:cast(?MODULE, {sub, Client}),
    ok.

handle_cast({pub, Event}, State) ->
    #{subscribers := Subs} = State,
    % one id for the tweet
    Id1 = uuid:to_string(uuid:uuid1()),
    % another for any retweet or quote tweet
    Id2 = uuid:to_string(uuid:uuid1()),
    functions:send_to_subscribers(Subs, {Event, Id1, Id2}),
    {noreply, State};
handle_cast({sub, Client}, State) ->
    #{subscribers := Subs} = State,
    NewState = #{subscribers => Subs ++ [Client]},
    {noreply, NewState}.
