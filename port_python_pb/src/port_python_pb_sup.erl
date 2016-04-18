%%%-------------------------------------------------------------------
%% @doc port_python_pb top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(port_python_pb_sup).

-behaviour(supervisor).

%% API
-export([start_link/0]).

%% Supervisor callbacks
-export([init/1]).

-define(SERVER, ?MODULE).

%%====================================================================
%% API functions
%%====================================================================

start_link() ->
    supervisor:start_link({local, ?SERVER}, ?MODULE, []).

%%====================================================================
%% Supervisor callbacks
%%====================================================================

%% Child :: {Id,StartFunc,Restart,Shutdown,Type,Modules}
init([]) ->
    Child = {port_python_pb_srv,
             {port_python_pb_srv, start_link, []},
             permanent,
             5000,
             worker,
             [port_python_pb]},
    {ok, { {one_for_all, 0, 1}, [Child]} }.

%%====================================================================
%% Internal functions
%%====================================================================
