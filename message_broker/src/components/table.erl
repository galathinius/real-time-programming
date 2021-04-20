-module(table).

-behaviour(gen_server).

-export([add_sub/1,
         add_sub_to_topics/2,
         add_topics/1,
         check_sub_E/1,
         check_topic_E/1,
         get_sub_list/0,
         get_subs_of_topic/1,
         get_topic_list/0,
         handle_cast/2,
         init/1,
         remove_sub_from_topics/2,
         start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE},
                          ?MODULE,
                          [],
                          []).

init([]) ->
    io:format("started table ~p~n", [self()]),
    ets:new(subscriptions,
            [bag, named_table, {read_concurrency, true}]),
    ets:new(ids, [bag, named_table]),
    % by default only the table owner can write to it, and everyone can read
    {ok, #{}}.

% subs -> [
%   {topic1, {id1, sock}},
%   {topic1, {id2, sock}},
%   {topic2, {id1, sock}},
% ... ]
add_sub(Id) -> gen_server:cast(?MODULE, {add_sub, Id}).

add_sub_to_topics(Sub, Topic) ->
    gen_server:cast(?MODULE, {add_sub, Sub, Topic}).

remove_sub_from_topics(SubId, Topic) ->
    gen_server:cast(?MODULE, {remove_sub, SubId, Topic}).

add_topics(Topic) ->
    gen_server:cast(?MODULE, {add_topic, Topic}).

get_subs_of_topic(Topic) ->
    ets:match(subscriptions, {Topic, {'_', '$1'}}).

get_topic_list() -> ets:match(ids, {topic, '$1'}).

get_sub_list() -> ets:match(ids, {id, '$1'}).

handle_cast({add_sub, Id}, State) ->
    ets:insert(ids, {id, Id}),
    {noreply, State};
handle_cast({add_sub, Sub, Topics}, State) ->
    [ets:insert(subscriptions, {Topic, Sub})
     || Topic <- Topics],
    {noreply, State};
handle_cast({remove_sub, SubId, Topics}, State) ->
    [ets:match_delete(subscriptions, {Topic, {SubId, '_'}})
     || Topic <- Topics],
    {noreply, State};
handle_cast({add_topic, Topics}, State) ->
    [ets:insert(ids, {topic, Topic}) || Topic <- Topics],
    {noreply, State}.

check_topic_E(Topic) ->
    lists:member([Topic], get_topic_list()).

check_sub_E(Id) -> lists:member([Id], get_sub_list()).
