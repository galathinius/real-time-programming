-module(sink).

-behaviour(gen_server).

-export([add_event/3,
         handle_cast/2,
         handle_info/2,
         init/1,
         start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE},
                          ?MODULE,
                          [],
                          []).

init([]) ->
    TimerRef = erlang:start_timer(700, self(), "timeout"),
    % io:format("~p~p~n", ["sink", self()]),
    {ok, {[], [], [], TimerRef}}.

add_event(User, Tweet, Id) ->
    gen_server:cast(?MODULE, {event, {User, Tweet, Id}}),
    ok.

handle_cast({event, {User, Tweet, Id}}, State) ->
    % add event to batch
    {Users, Tweets, Relations, TimerRef} = State,
    NewUsers = Users ++ [{User}],
    NewTweets = Tweets ++ [{Tweet}],
    NewRelations = Relations ++ [{Id}],
    % check batch size
    if length(NewRelations) < 100 ->
           NewState = {NewUsers,
                       NewTweets,
                       NewRelations,
                       TimerRef};
       true ->
           erlang:cancel_timer(TimerRef),
           NewTimer = send_to_db({Users, Tweets, Relations}),
           NewState = {[], [], [], NewTimer}
    end,
    {noreply, NewState}.

% handle timeout
handle_info({timeout, _, _}, State) ->
    {Users, Tweets, Relations, _TimerRef} = State,
    NewTimer = send_to_db({Users, Tweets, Relations}),
    {noreply, {[], [], [], NewTimer}}.

send_to_db(Events) ->
    database:add_events(Events),
    erlang:start_timer(700, self(), "timeout").
