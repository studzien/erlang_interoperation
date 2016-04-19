%%%-------------------------------------------------------------------
%% @doc driver_c top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(driver_c_sup).

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
    Control = {driver_c_control,
               {driver_c_control, start_link, []},
               permanent, 5000, worker, [driver_c_control]},
    {ok, { {one_for_all, 0, 1}, [
                                 Control
                                ]} }.

%%====================================================================
%% Internal functions
%%====================================================================
