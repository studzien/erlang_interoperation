-module(c_calc_srv).

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
    Port = erlang:open_port({spawn, port_path()}, [binary, {packet, 2}]),
    {ok, #{port => Port}}.

handle_call(Request, From, State) ->
    port_request(Request, From, State),
    {noreply, State}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({Port, {data, Data}}, #{port := Port}=State) ->
    {Response, Client} = erlang:binary_to_term(Data),
    gen_server:reply(Client, Response),
    {noreply, State};
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
    Dir = code:priv_dir(c_calc),
    filename:join([Dir, "port_c_ext"]).

port_request(Request, From, #{port := Port}) ->
    RequestEXT = erlang:term_to_binary({Request, From}),
    true = erlang:port_command(Port, RequestEXT).
