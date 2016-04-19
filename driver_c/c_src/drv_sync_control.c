#include <stdio.h>
#include <assert.h>
#include <string.h>
#include <stdio.h>

#include "erl_driver.h"
#include "ei.h"

static long calculate(unsigned int command, long x, long y);

typedef struct {
    ErlDrvPort port;
} example_data;


static ErlDrvData start(ErlDrvPort port, char *buff)
{
    example_data* d = (example_data*)driver_alloc(sizeof(example_data));
    d->port = port;
    set_port_control_flags(port, PORT_CONTROL_FLAG_BINARY);
    return (ErlDrvData)d;
}

static void stop(ErlDrvData handle)
{
    driver_free((char*)handle);
}

static ErlDrvSSizeT control(ErlDrvData handle, unsigned int command,
        char *buf, ErlDrvSizeT len, char **rbuf, ErlDrvSizeT rlen) {
    int i = 0, arity;
    long x, y;
    assert(ei_decode_version(buf, &i, NULL) == 0);
    assert(ei_decode_tuple_header(buf, &i, &arity) == 0);
    assert(arity == 2);
    assert(ei_decode_long(buf, &i, &x) == 0);
    assert(ei_decode_long(buf, &i, &y) == 0);
    
    ei_x_buff xbuff;
    assert(ei_x_new_with_version(&xbuff) == 0);
    long result = calculate(command, x, y);
    assert(ei_x_encode_long(&xbuff, result) == 0);

    ErlDrvSSizeT n = xbuff.index;
    if(n > rlen) {
        ErlDrvBinary *bin = driver_alloc_binary(n);
        assert(bin != NULL);
        memcpy(bin->orig_bytes, xbuff.buff, n);
        *rbuf = (char*)bin;
    }
    else {
        memcpy(*rbuf, xbuff.buff, n);
    }
    assert(ei_x_free(&xbuff) == 0);
    return n;
}

static long calculate(unsigned int command, long x, long y) {
    switch(command) {
        case 0: return x+y;
        case 1: return x-y;
        case 2: return x*y;
        case 3: return x/y;
        default: return 0;
    }
}

ErlDrvEntry drv_sync_control_entry = {
    NULL,			/* F_PTR init, called when driver is loaded */
    start,		/* L_PTR start, called when port is opened */
    stop,		/* F_PTR stop, called when port is closed */
    NULL,		/* F_PTR output, called when erlang has sent */
    NULL,			/* F_PTR ready_input, called when input descriptor ready */
    NULL,			/* F_PTR ready_output, called when output descriptor ready */
    "drv_sync_control",		/* char *driver_name, the argument to open_port */
    NULL,			/* F_PTR finish, called when unloaded */
    NULL,                       /* void *handle, Reserved by VM */
    control,			/* F_PTR control, port_command callback */
    NULL,			/* F_PTR timeout, reserved */
    NULL,			/* F_PTR outputv, reserved */
    NULL,                       /* F_PTR ready_async, only for async drivers */
    NULL,                       /* F_PTR flush, called when port is about 
                                   to be closed, but there is data in driver 
                                   queue */
    NULL,                       /* F_PTR call, much like control, sync call
                                   to driver */
    NULL,                       /* F_PTR event, called when an event selected 
                                   by driver_event() occurs. */
    ERL_DRV_EXTENDED_MARKER,    /* int extended marker, Should always be 
                                   set to indicate driver versioning */
    ERL_DRV_EXTENDED_MAJOR_VERSION, /* int major_version, should always be 
                                       set to this value */
    ERL_DRV_EXTENDED_MINOR_VERSION, /* int minor_version, should always be 
                                       set to this value */
    0,                          /* int driver_flags, see documentation */
    NULL,                       /* void *handle2, reserved for VM use */
    NULL,                       /* F_PTR process_exit, called when a 
                                       monitored process dies */
    NULL                        /* F_PTR stop_select, called to close an 
                                   event object */
};

DRIVER_INIT(drv_sync_control) /* must match name in driver_entry */
{
    return &drv_sync_control_entry;
}

