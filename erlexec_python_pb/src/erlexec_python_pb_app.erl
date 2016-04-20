%%%-------------------------------------------------------------------
%% @doc erlexec_python_pb public API
%% @end
%%%-------------------------------------------------------------------

-module(erlexec_python_pb_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    erlexec_python_pb_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
