-module(information).

-behaviour(gen_server).

-export([get_info/0, handle_call/3, handle_cast/2,
	 init/1, log_event/1, log_panic/0, log_score/0,
	 start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["information", self()]),
    event_publisher:subscribe({?MODULE, log_event, []}),
    {ok, #{events => 0, panics => 0, actual_scores => 0}}.

log_event(_) -> gen_server:cast(?MODULE, {tweet}).

log_panic() -> gen_server:cast(?MODULE, {panic}).

log_score() -> gen_server:cast(?MODULE, {score}).

get_info() -> gen_server:call(?MODULE, {get_info}).

handle_call({get_info}, _From, State) ->
    {reply, State,
     #{events => 0, panics => 0, actual_scores => 0}}.

handle_cast({tweet}, State) ->
    #{events := Events, panics := Panics,
      actual_scores := Scores} =
	State,
    NewState = #{events => Events + 1, panics => Panics,
		 actual_scores => Scores},
    {noreply, NewState};
handle_cast({panic}, State) ->
    #{events := Events, panics := Panics,
      actual_scores := Scores} =
	State,
    NewState = #{events => Events, panics => Panics + 1,
		 actual_scores => Scores},
    {noreply, NewState};
handle_cast({score}, State) ->
    #{events := Events, panics := Panics,
      actual_scores := Scores} =
	State,
    NewState = #{events => Events, panics => Panics,
		 actual_scores => Scores + 1},
    {noreply, NewState}.
