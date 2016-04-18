port_python_ext
=====
- Type: Port
- Serialization: [External Term
  Format](http://erlang.org/doc/apps/erts/erl_ext_dist.html) via stdin/stdout
- Language: Python (with [erlport](http://erlport.org/))

Prerequisites
-------------
    $ pip install erlport

Build
-----
    $ rebar3 compile

Tests
-----
    $ rebar3 eunit

Example
-------
    $ rebar3 shell --apps=port_python_ext
    Erlang/OTP 17 [erts-6.4] [source] [64-bit] [smp:4:4] [async-threads:0] [kernel-poll:false]
    
    Eshell V6.4  (abort with ^G)
    1> port_python_ext_srv:add(2,5).
    7
    2> port_python_ext_srv:sub(100,15).
    85
    3> port_python_ext_srv:mul(5,9).
    45
    4> port_python_ext_srv:'div'(100, 2).
    50
