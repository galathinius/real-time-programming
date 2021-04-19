-module(messages).

-export([data_message/2,
         deserialize/1,
         publish_request/1,
         subscribe_request/1,
         subscribe_request/2,
         topic_request/0,
         unsubscribe_request/2]).

deserialize(Message) -> jiffy:decode(Message).

% message types:

% data ; topics
% topics: [t1, t2] ; data: data
data_message(Data, Topics) ->
    jiffy:encode(#{<<"topics">> => Topics,
                   <<"data">> => Data}).

%
 % messages:data_message(<<"aaadata">>,[<<"t1">>]).

% pub req ; topics
% req: pub ; topics: [t1, t2]
publish_request(Topics) ->
    jiffy:encode(#{<<"request">> => <<"publish">>,
                   <<"topics">> => Topics}).

% get topics
% req: topics
topic_request() ->
    jiffy:encode(#{<<"request">> => <<"topics">>}).

% sub req ; topics
% req: sub ; topics: [t1, t2]
subscribe_request(Topics) ->
    jiffy:encode(#{<<"request">> => <<"subscribe">>,
                   <<"topics">> => Topics}).

% sub req ; id ; topics
% req: sub ; id : id ; topics: [t1, t2]
subscribe_request(Id, Topics) ->
    jiffy:encode(#{<<"request">> => <<"subscribe">>,
                   <<"id">> => <<Id>>, <<"topics">> => Topics}).

% unsub req ; id ; topics
% req: unsub ; id : id ; topics: [t1, t2]
unsubscribe_request(Id, Topics) ->
    jiffy:encode(#{<<"request">> => <<"unsubscribe">>,
                   <<"id">> => <<Id>>, <<"topics">> => Topics}).
