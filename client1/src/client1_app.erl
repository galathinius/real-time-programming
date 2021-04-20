%%%-------------------------------------------------------------------
%% @doc client1 public API
%% @end
%%%-------------------------------------------------------------------

-module(client1_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    wait(200),
    client1_sup:start_link().

stop(_State) -> ok.

wait(Units) -> receive  after 10 * Units -> ok end.

%% internal functions

