-module(table).

-behaviour(gen_server).

-export([add_sub_to_topics/2,
         add_topics/1,
         get_subs_of_topic/1,
         get_topic_list/0,
         handle_call/3,
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
    ets:new(topics, [bag, named_table]),
    % by default only the table owner can write to it, and everyone can read
    io:format("~p~p~n", ["database", self()]),
    {ok, #{}}.

% subs -> [
%   {topic1, {id1, sock}},
%   {topic1, {id2, sock}},
%   {topic2, {id1, sock}},
% ... ]

add_sub_to_topics(Sub, Topic) ->
    % true
    % Sub = {Id, sock}
    gen_server:cast(?MODULE, {add_sub, Sub, Topic}).

remove_sub_from_topics(SubId, Topic) ->
    % true
    gen_server:cast(?MODULE, {remove_sub, SubId, Topic}).

add_topics(Topic) ->
    gen_server:cast(?MODULE, {add_topic, Topic}).

get_subs_of_topic(Topic) ->
    % [[sock1],[sock]]
    % gen_server:call(?MODULE, {get_subs, Topic}).
    ets:match(subscriptions, {Topic, {'_', '$1'}}).

get_topic_list() ->
    % [[topic1],[topic2]]
    % gen_server:call(?MODULE, {get_topics}).
    ets:match(topics, {topic, '$1'}).

handle_cast({add_sub, Sub, Topics}, State) ->
    [ets:insert(subscriptions, {Topic, Sub})
     || Topic <- Topics],
    {noreply, State};
handle_cast({remove_sub, SubId, Topics}, State) ->
    [ets:match_delete(subscriptions, {Topic, {SubId, '_'}})
     || Topic <- Topics],
    {noreply, State};
handle_cast({add_topic, Topics}, State) ->
    [ets:insert(topics, {topic, Topic}) || Topic <- Topics],
    {noreply, State}.

handle_call({get_subs, Topic}, _From, State) ->
    Subs = ets:match(subscriptions, {Topic, {'_', '$1'}}),
    {reply, Subs, State};
handle_call({get_topics}, _From, State) ->
    Topics = ets:match(topics, {topic, '$1'}),
    {reply, Topics, State}.

%
% testing
%
% table:add_topics(topic1).
% table:add_topics(topic2).
% table:get_topic_list().

% table:add_sub_to_topics({"id2", sock2}, topic1).
% table:add_sub_to_topics({"id1", sock1}, topic2).
% table:add_sub_to_topics({"id1", sock1}, topic1).
%
% table:get_subs_of_topic(topic1).
%
% table:remove_sub_from_topics("id1", topic1).

