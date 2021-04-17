-module(receiving).

-export([process_message/3]).

% registers client as publisher
process_message(#{<<"request">> := <<"publish">>,
                  <<"topics">> := Topics},
                ListenSocket, SendSock) ->
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
process_message(#{<<"request">> := <<"topics">>},
                ListenSocket, SendSock) ->
    % get topics
    Topics = table:get_topic_list(),
    % send topics
    gen_tcp:send(SendSock, Topics),
    % continue listening to this connection
    listening_socket:handle_connection(ListenSocket);
%
% new subscribe request
process_message(#{<<"request">> := <<"subscribe">>,
                  <<"topics">> := Topics},
                ListenSocket, SendSock) ->
    % create id
    Id = uuid:to_string(uuid:uuid1()),
    % send id
    gen_tcp:send(SendSock, Id),
    % get topics
    Topics = table:get_topic_list(),
    % check topics exist
    % add subscriber to topics
    % wait for another connection
    % check for bug, if conn is not closed
    listening_socket:accept(ListenSocket).

%
% subscribe request from already registered client
% check id is in list
% send id
% gen_tcp:send(SendSock, Id),
% get topics
% Topics = table:get_topic_list(),
% check topics exist
% add subscriber to topics
% wait for another connection

%
% unsubscribe request
% check id is in list
% send id
% gen_tcp:send(SendSock, Id),
% get topics
% Topics = table:get_topic_list(),
% check topics exist
% remove subscriber to topics
% wait for another connection

