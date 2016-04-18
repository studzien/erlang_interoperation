port_c_ext
=====
- Type: Port
- Serialization: [External Term
  Format](http://erlang.org/doc/apps/erts/erl_ext_dist.html) via stdin/stdout
- Language: C (ei library from Erlang/OTP)

Build
-----
    $ rebar3 compile

Tests
-----
    $ rebar3 eunit

Example
-------
    $ rebar3 shell --apps=c_calc
    Erlang/OTP 17 [erts-6.4] [source] [64-bit] [smp:4:4] [async-threads:0] [kernel-poll:false]
    
    Eshell V6.4  (abort with ^G)
    1> c_calc_srv:add(2,5).
    7
    2> c_calc_srv:sub(100,15).
    85
    3> c_calc_srv:mul(5,9).
    45
    4> c_calc_srv:'div'(100, 2).
    50
