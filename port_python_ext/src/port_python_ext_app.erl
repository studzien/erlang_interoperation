%%%-------------------------------------------------------------------
%% @doc port_python_ext public API
%% @end
%%%-------------------------------------------------------------------

-module(port_python_ext_app).

-behaviour(application).

%% Application callbacks
-export([start/2, stop/1]).

%%====================================================================
%% API
%%====================================================================

start(_StartType, _StartArgs) ->
    port_python_ext_sup:start_link().

%%--------------------------------------------------------------------
stop(_State) ->
    ok.

%%====================================================================
%% Internal functions
%%====================================================================
