-module(functions).

-export([get_tweet/1, thinking/0, wait/1]).

get_tweet(Event) ->
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

wait(Units) -> receive  after 10 * Units -> ok end.

thinking() ->
    Ra = rand:uniform(),
    Int = round(Ra * 100),
    wait(Int),
    ok.
