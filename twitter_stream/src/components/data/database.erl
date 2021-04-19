-module(database).

-behaviour(gen_server).

-export([add_events/1,
         handle_cast/2,
         init/1,
         start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE},
                          ?MODULE,
                          [],
                          []).

init([]) ->
    ets:new(users, [set, named_table]),
    ets:new(tweets, [set, named_table]),
    ets:new(relationship, [set, named_table]),
    % io:format("~p~p~n", ["database", self()]),
    {ok, #{}}.

% users -> [{id, user}, {id2, user2}, ... ]
% tweets -> [{id, tweet}, {id2, tweets}, ... ]
% relationship -> [{eventId, userId, tweetId}, ... ]

add_events(Events) ->
    gen_server:cast(?MODULE, {events, Events}),
    ok.

handle_cast({events, Events}, State) ->
    {Users, Tweets, Relations} = Events,
    % io:format("db  ~p ~n", [length(Relations)]),
    ets:insert(users, Users),
    ets:insert(tweets, Tweets),
    ets:insert(relationship, Relations),
    {noreply, State}.
