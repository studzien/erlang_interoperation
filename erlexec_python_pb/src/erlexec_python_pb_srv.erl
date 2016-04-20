-module(erlexec_python_pb_srv).

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

-include("calc_pb.hrl").

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
    {ok, PortPid, OsPid} = exec:run_link(port_path(), [stdin, stdout]),
    {ok, #{port => PortPid, buffer => <<>>, os_pid => OsPid}}.

handle_call({Op, X, Y}, From, State) ->
    Request = #'Calculation'{operation = Op, arg1 = X, arg2 = Y},
    port_request(Request, State),
    {noreply, State#{reply_to => From}}.

handle_cast(_Msg, State) ->
    {noreply, State}.

handle_info({stdout, OsPid, Data}, #{os_pid := OsPid}=State) ->
    NewState = append_buffer_or_decode(Data, State),
    {noreply, NewState};
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
    Dir = code:priv_dir(erlexec_python_pb),
    filename:join([Dir, "py_calc.py"]).

port_request(Request, #{port := Port}) ->
    RequestPB = calc_pb:encode_msg(Request, [verify]),
    Size = erlang:byte_size(RequestPB),
    Packet = <<Size:16, RequestPB/binary>>,
    ok = exec:send(Port, Packet).

append_buffer_or_decode(Data, #{buffer := Buffer, reply_to := From}=State) ->
    NewBuffer = <<Buffer/binary, Data/binary>>,
    case maybe_decode_packet(NewBuffer) of
        {Decoded, Rest} ->
            #'Result'{result = Result} = calc_pb:decode_msg(Decoded, 'Result'),
            gen_server:reply(From, Result),
            State#{buffer => Rest};
        continue ->
            State#{buffer => NewBuffer}
    end.

maybe_decode_packet(<<Size:16, Rest/binary>>) ->
    case byte_size(Rest) of
        S when S >= Size ->
            erlang:split_binary(Rest, Size);
        _ ->
            continue
    end;
maybe_decode_packet(_) ->
    continue.
