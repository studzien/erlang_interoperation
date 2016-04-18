-module(port_python_pb_test).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

ops_test() ->
    given_application_started(),
    Ops = given_random_ops(1024),
    Result = when_ops_performed_by_port(Ops),
    then_result_is_correct(Ops, Result).

given_application_started() ->
    ok = application:ensure_started(port_python_pb),
    random:seed(os:timestamp()).

given_random_ops(N) ->
    [ {random_op(), random_int(), random_int()} || _ <- lists:seq(1, N) ].

when_ops_performed_by_port(Ops) ->
    [ apply(port_python_pb_srv, Op, [Arg1, Arg2]) || {Op, Arg1, Arg2} <- Ops ].

then_result_is_correct(Ops, Result) ->
    Correct = [ correct_result(Op) || Op <- Ops ],
    ?assertEqual(Result, Correct).

random_int() ->
    random:uniform(20000).

random_op() ->
    Ops = {add, sub, mul, 'div'},
    element(random:uniform(size(Ops)), Ops).

correct_result({add, X, Y}) -> X + Y;
correct_result({sub, X, Y}) -> X - Y;
correct_result({mul, X, Y}) -> X * Y;
correct_result({'div', X, Y}) -> X div Y.
