-module(router).

-behaviour(gen_server).

-export([fire_worker/1, handle_cast/2, init/1,
	 register_worker/1, route/1, start_link/0]).

start_link() ->
    gen_server:start_link({local, ?MODULE}, ?MODULE, [],
			  []).

init([]) ->
    io:format("~p~p~n", ["router", self()]),
    {ok, #{pids => []}}.

route(Tweet) ->
    gen_server:cast(?MODULE, {tweet, Tweet}), ok.

register_worker(Pid) ->
    gen_server:cast(?MODULE, {hye, Pid}), ok.

fire_worker(Pid) ->
    gen_server:cast(?MODULE, {bye, Pid}), ok.

handle_cast({tweet, Tweet}, State) ->
    #{pids := Pids} = State,
    [Head | Tail] = Pids,
    Head ! Tweet,
    NewState = #{pids => Tail ++ [Head]},
    {noreply, NewState};
handle_cast({hye, Pid}, State) ->
    #{pids := Pids} = State,
    NewState = #{pids => Pids ++ [Pid]},
    io:format("~p~p~n", [Pid, NewState]),
    {noreply, NewState};
handle_cast({bye, Pid}, State) ->
    #{pids := Pids} = State,
    NewPids = lists:delete(Pid, Pids),
    NewState = #{pids => NewPids},
    {noreply, NewState}.
