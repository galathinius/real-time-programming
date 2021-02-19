-module(router).

-behaviour(gen_server).

-export([handle_cast/2, init/1, route/1, start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) -> {ok, #{}}.

route(Tweets) ->
    gen_server:cast(?MODULE, {tweets, Tweets}), ok.

handle_cast({tweets, Tweets}, State) ->
    process_events(Tweets), {noreply, State}.

process_events([Event]) -> worker:work(Event);
process_events(Events) ->
    [Head | Tail] = Events,
    worker:work(Head),
    process_events(Tail).

% call e blocking, cast e non-bloking, handle info e pentru mesaje primite fara call sau cast

% my_api_2(A, B) ->
%     gen_server:call(?MODULE, {msg2, A, B}).

% my_api_3(A, B, C) ->
%     gen_server:call(?MODULE, {msg3, A, B, C}).

% handle_call({msg1, A}, _From, State) ->
%   ...

% handle_call({msg2, A, B}, _From, State) ->
%   ...

% handle_call({msg3, A, B, C}, _From, State) ->
%   ...

% do_something(A, B) ->
%     gen_server:cast(?MODULE, {do_something, A, B}),
%     ok.
%
% handle_cast({do_something, A, B}, State) ->
%     NewState = ...
%     {noreply, NewState};

% handle_info({some_message, A, B}, State) ->
%     NewState = ...
%     {noreply, NewState};

