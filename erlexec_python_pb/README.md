erlexec_python_pb
=================
- Type: Port ([erlexec](https://github.com/saleyn/erlexec.git))
- Serialization: [Protocol
  Buffers](https://developers.google.com/protocol-buffers/) via
stdin/stdout
- Language: Python

Prerequisites
-------------
You need to have ``protoc`` installed in order to generate a python
module.

Build
-----
    $ rebar3 compile

Tests
-----
    $ rebar3 eunit

Example
-------
    $ rebar3 shell --apps=erlexec_python_pb
    Erlang/OTP 17 [erts-6.4] [source] [64-bit] [smp:4:4] [async-threads:0] [kernel-poll:false]
    
    Eshell V6.4  (abort with ^G)
    1> erlexec_python_pb_srv:add(2,5).
    7
    2> erlexec_python_pb_srv:sub(100,15).
    85
    3> erlexec_python_pb_srv:mul(5,9).
    45
    4> erlexec_python_pb_srv:'div'(100, 2).
    50
