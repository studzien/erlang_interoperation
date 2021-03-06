%%%-------------------------------------------------------------------
%% @doc c_calc top level supervisor.
%% @end
%%%-------------------------------------------------------------------

-module(c_calc_sup).

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
    Calc = {c_calc_srv,
           {c_calc_srv, start_link, []},
           permanent, 5000, worker, [c_calc_srv]},
    {ok, { {one_for_all, 0, 1}, [Calc]} }.

%%====================================================================
%% Internal functions
%%====================================================================
