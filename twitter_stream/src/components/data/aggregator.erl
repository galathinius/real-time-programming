-module(aggregator).

-behaviour(gen_server).

-export([add_emotion/2,
         add_engagement/2,
         add_tweet/2,
         handle_cast/2,
         init/1,
         start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE},
                          ?MODULE,
                          [],
                          []).

init([]) ->
    % io:format("~p~p~n", ["aggregator", self()]),
    {ok, #{}}.

add_tweet(Tweet, Id) ->
    gen_server:cast(?MODULE, {tweet, Tweet, Id}).

add_emotion(Score, Id) ->
    gen_server:cast(?MODULE, {emotional_score, Score, Id}).

add_engagement(Score, Id) ->
    gen_server:cast(?MODULE, {engagement_score, Score, Id}).

handle_cast({Field, Value, Id}, State) ->
    % get the info we have about the tweet, if nothing then  empty map
    TweetInfo = maps:get(Id, State, #{}),
    % add the information we just got to the tweet
    UpdatedTweet = maps:put(Field, Value, TweetInfo),
    % update state
    NewState = update_state(UpdatedTweet,
                            Id,
                            State,
                            chek_complete(UpdatedTweet)),
    % return new state
    {noreply, NewState}.

update_state(UpdatedTweet, Id, State, 3) ->
    aggregator_pub:publish({UpdatedTweet, Id}),
    maps:remove(Id, State);
update_state(UpdatedTweet, Id, State, Count)
    when Count < 3 ->
    maps:put(Id, UpdatedTweet, State).

chek_complete(TweetInfo) ->
    length(maps:keys(TweetInfo)).
