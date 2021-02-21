%%%-------------------------------------------------------------------
%% @doc twitter_stream public API
%% @end
%%%-------------------------------------------------------------------

-module(twitter_stream_app).

-behaviour(application).

-export([start/2, stop/1]).

start(_StartType, _StartArgs) ->
    twitter_stream_sup:start_link().

stop(_State) -> ok.
