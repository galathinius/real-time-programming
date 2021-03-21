-module(information_transformer).

-behaviour(gen_server).

-export([add_event/2, handle_cast/2, init/1,
	 start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["info transformer ", self()]),
    {ok, #{}}.

add_event(Event, Id) ->
    gen_server:cast(?MODULE, {event, Event, Id}), ok.

handle_cast({event, Event, Id}, State) ->
    {User, Tweet} = transform(Event),
    send_to_sink(User, Tweet, Id),
    {noreply, State}.

send_to_sink(User, Tweet, RelationalId) ->
    UserId = uuid:to_string(uuid:uuid1()),
    TweetId = uuid:to_string(uuid:uuid1()),
    sink:add_event({UserId, User}, {TweetId, Tweet},
		   {RelationalId, UserId, TweetId}).

transform(Event) ->
    % add scores to tweet
    TweetWithScores = add_scores_to_tweet(Event),
    % separate the user and return
    separate_user(TweetWithScores).

separate_user(Event) ->
    % get user
    #{<<"user">> := User} = Event,
    % return touple of user and tweet w/out user
    {User, maps:remove(<<"user">>, Event)}.

add_scores_to_tweet(Event) ->
    % add emotional score
    WithEmotional = maps:update(tweet,
				add_emotional_score(Event), Event),
    % add engagement and return
    add_engagement_score(WithEmotional).

add_emotional_score(Event) ->
    % extract score
    #{tweet := Tweet, emotional_score := Score} = Event,
    % add as binary string
    maps:put(<<"emotional_score">>, Score, Tweet).

add_engagement_score(Event) ->
    % extract score
    #{tweet := Tweet, engagement_score := Score} = Event,
    % add as binary string
    maps:put(<<"engagement_score">>, Score, Tweet).
