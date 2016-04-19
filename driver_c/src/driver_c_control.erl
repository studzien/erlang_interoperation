-module(driver_c_control).

-behaviour(gen_server).

%% API
-export([start_link/0,
         add/2,
         sub/2,
         mul/2,
         'div'/2]).

%% gen_server callbacks
-export([init/1,
         handle_call/3,
         handle_cast/2,
         handle_info/2,
         terminate/2,
         code_change/3]).

-define(SERVER, ?MODULE).

%%%===================================================================
%%% API
%%%===================================================================
start_link() ->
    gen_server:start_link({local, ?SERVER}, ?MODULE, [], []).

add(X, Y) ->
    gen_server:call(?SERVER, {add, X, Y}).

sub(X, Y) ->
    gen_server:call(?SERVER, {sub, X, Y}).

mul(X, Y) ->
    gen_server:call(?SERVER, {mul, X, Y}).

'div'(X, Y) ->
    gen_server:call(?SERVER, {'div', X, Y}).

%%%===================================================================
%%% gen_server callbacks
%%%===================================================================
init([]) ->
    ok = erl_ddll:load(port_path(), drv_sync_control),
    Port = erlang:open_port({spawn, drv_sync_control}, [binary]),
    {ok, #{port => Port}}.

handle_call(Request, _From, State) ->
    Reply = port_request(Request, State),
    {reply, Reply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info(_Info, State) ->
    {noreply, State}.

terminate(_Reason, _State) ->
    ok.

code_change(_OldVsn, State, _Extra) ->
    {ok, State}.

%%%===================================================================
%%% Internal functions
%%%===================================================================
port_path() ->
    code:priv_dir(driver_c).

port_request({Op, X, Y}, #{port := Port}) ->
    Result = erlang:port_control(Port, opcode(Op),
                                 erlang:term_to_binary({X, Y})),
    erlang:binary_to_term(Result).

opcode(add) -> 0;
opcode(sub) -> 1;
opcode(mul) -> 2;
opcode('div') -> 3.
