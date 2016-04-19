-module(driver_c_test).

-compile(export_all).

-include_lib("eunit/include/eunit.hrl").

port_control_test() ->
    given_application_started(),
    Ops = given_random_ops(1024),
    Result = when_ops_performed_by_port_control(Ops),
    then_result_is_correct(Ops, Result).

given_application_started() ->
    ok = application:ensure_started(driver_c),
    random:seed(os:timestamp()).

given_random_ops(N) ->
    [ {random_op(), random_int(), random_int()} || _ <- lists:seq(1, N) ].

when_ops_performed_by_port_control(Ops) ->
    perform_ops_on(driver_c_control, Ops).

perform_ops_on(Module, Ops) ->
    [ apply(Module, Op, [Arg1, Arg2]) || {Op, Arg1, Arg2} <- Ops ].

then_result_is_correct(Ops, Result) ->
    Correct = [ correct_result(Op) || Op <- Ops ],
    ?assertEqual(Correct, Result).

random_int() ->
    random:uniform(20000).

random_op() ->
    Ops = {add, sub, mul, 'div'},
    element(random:uniform(size(Ops)), Ops).

correct_result({add, X, Y}) -> X + Y;
correct_result({sub, X, Y}) -> X - Y;
correct_result({mul, X, Y}) -> X * Y;
correct_result({'div', X, Y}) -> X div Y.
