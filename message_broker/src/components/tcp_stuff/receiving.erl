-module(receiving).

-export([process_message/3]).

% registers client as publisher
process_message({[{<<"request">>, <<"publish">>},
                  {<<"topics">>, Topics}]},
                ListenSocket, SendSock) ->
    io:format("got a publisher req ~p~n", [self()]),
    % register topics
    table:add_topics(Topics),
    % send ok
    % gen_tcp:send(SendSock, <<"ok">>),
    % create another free listening actor
    listening_socket_sup:start_listening(ListenSocket),
    % continue listening to this connection
    listening_socket:handle_connection(ListenSocket);
%
% topic request
process_message({[{<<"request">>, <<"topics">>}]},
                ListenSocket, SendSock) ->
    io:format("got a topic req ~p~n", [self()]),
    % get topics
    Topics = table:get_topic_list(),
    % send topics
    gen_tcp:send(SendSock, Topics),
    % continue listening to this connection
    listening_socket:handle_connection(ListenSocket);
%
% new subscribe request
process_message({[{<<"request">>, <<"subscribe">>},
                  {<<"topics">>, Topics}]},
                ListenSocket, SendSock) ->
    io:format("got a new sub req ~p for ~p ~n",
              [self(), Topics]),
    % create id
    Id = uuid:to_string(uuid:uuid1()),
    table:add_sub(Id),
    process_message({[{<<"id">>, Id},
                      {<<"request">>, <<"subscribe">>},
                      {<<"topics">>, Topics}]},
                    ListenSocket,
                    SendSock);
%
% subscribe request from already registered client
process_message({[{<<"id">>, Id},
                  {<<"request">>, <<"subscribe">>},
                  {<<"topics">>, Topics}]},
                ListenSocket, SendSock) ->
    io:format("got a old sub req ~p~n", [self()]),
    % check id
    table:check_sub_E(Id),
    % send id as confirmation
    gen_tcp:send(SendSock, Id),
    %
    % check topics exist
    % if the row below is uncommented then subs can only subscribe to existing topics
    % TopicsToSub = [Topic || Topic <- Topics, table:check_topic_E(Topic)],
    %
    % add subscriber to topics
    table:add_sub_to_topics({Id, SendSock}, Topics),
    % wait for another connection
    % check for bug, if conn is not closed
    listening_socket:accept(ListenSocket);
%
% unsubscribe request
process_message({[{<<"id">>, Id},
                  {<<"request">>, <<"unsubscribe">>},
                  {<<"topics">>, Topics}]},
                ListenSocket, SendSock) ->
    io:format("got a unsub req ~p~n", [self()]),
    % check id
    table:check_sub_E(Id),
    % send id as confirmation
    gen_tcp:send(SendSock, Id),
    % check topics exist
    TopicsToSub = [Topic
                   || Topic <- Topics, table:check_topic_E(Topic)],
    % remove subscriber from topics
    table:remove_sub_from_topics(Id, TopicsToSub),
    % wait for another connection
    % check for bug, if conn is not closed
    listening_socket:accept(ListenSocket);
process_message({[{<<"data">>, Data},
                  {<<"topics">>, Topics}]},
                ListenSocket, SendSock) ->
    io:format("got a dat mess ~p~n", [self()]),
    % idk, send along
    router:route(topic_distribution_router, {Data, Topics}),
    listening_socket:handle_connection(ListenSocket),
    ok.
