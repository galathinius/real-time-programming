-module(functions).

-export([get_json/1, get_tweet/1, is_quote_tweet/1,
	 is_retweet/1, thinking/0, wait/1]).

get_json(Event) ->
    Text = shotgun:parse_event(Event),
    #{data := Data} = Text,
    Isjson = jsx:is_json(Data),
    if Isjson == true -> {tweet, jsx:decode(Data)};
       true -> detect_panic(Data)
    end.

detect_panic(Map) ->
    TheMap = unicode:characters_to_list(Map, utf8),
    Index = string:str(TheMap, "panic"),
    if Index > 0 -> panic;
       true -> ok
    end.

get_tweet(Json) ->
    #{<<"message">> := #{<<"tweet">> := Tweet}} = Json,
    Tweet.

is_retweet(Tweet) ->
    IsRetweet = maps:get(<<"retweeted_status">>, Tweet,
			 false),
    IsRetweet.

is_quote_tweet(Tweet) ->
    IsQuote = maps:get(<<"quoted_status">>, Tweet, false),
    IsQuote.

% quoted_status

wait(Units) -> receive  after 10 * Units -> ok end.

thinking() ->
    Ra = rand:uniform(),
    Int = round(Ra * 100),
    wait(Int),
    ok.
