-module(aggregator).

-behaviour(gen_server).

-export([add_emotion/2, add_engagement/2, add_tweet/2,
	 handle_cast/2, init/1, start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["aggregator", self()]), {ok, #{}}.

add_tweet(Tweet, Id) ->
    gen_server:cast(?MODULE, {tweet, Tweet, Id}).

add_emotion(Score, Id) ->
    gen_server:cast(?MODULE, {emotional_score, Score, Id}).

add_engagement(Score, Id) ->
    gen_server:cast(?MODULE, {engagement_score, Score, Id}).

handle_cast({Field, Tweet, Id}, State) ->
    TweetInfo = maps:get(Id, State, #{}),
    UpdatedTweet = maps:put(Field, Tweet, TweetInfo),
    NewState = update_state(UpdatedTweet, Id, State,
			    chek_complete(UpdatedTweet)),
    {noreply, NewState}.

update_state(UpdatedTweet, Id, State, 3) ->
    % sink:add_tweet(UpdatedTweet, Id),
    io:format("agregated: ~p ~n", [UpdatedTweet]),
    maps:remove(Id, State);
update_state(UpdatedTweet, Id, State, Count)
    when Count < 3 ->
    maps:put(Id, UpdatedTweet, State).

chek_complete(TweetInfo) ->
    length(maps:keys(TweetInfo)).

% to do :
%  put them in the supervizor and check if they work

