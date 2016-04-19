driver_c
=====
- Type: Linked-in Port Driver
- Serialization: [External Term
  Format](http://erlang.org/doc/apps/erts/erl_ext_dist.html) via port callbacks
- Language: C (erl_interface, ei)

Build
-----
    $ rebar3 compile

Tests
-----
    $ rebar3 eunit

To do
-----
- [ ] synchronous via messages
- [X] synchronous via ``port_control`` (binary)
- [ ] synchronous via ``port_control`` (list)
- [ ] synchronous via ``port_call``
- [ ] asynchronous
- [ ] via file descriptors

Caveats
-------
- ``port_control`` port callback is weird.
If the driver has set ``set_port_control_flags(port, PORT_CONTROL_FLAG_BINARY)``
then the callback is expected to return ``ErlDrvBinary`` allocated via
``driver_alloc_binary`` in the return buffer, but iff it exceeds the
return buffer size passed by the caller.
If flag is not set, the port is
expected to return a ``char*`` allocated via ``driver_alloc``, also only
if the buffer exceeds the original return buffer.
In both cases, allocation is freed by port control logic inside the VM.
The callback always does return the byte length, the port control logic
recalculates it in case of ``ErlDrvBinary``.
