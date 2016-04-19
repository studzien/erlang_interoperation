#include <ei.h>
#include <erl_interface.h>
#include <unistd.h>
#include <assert.h>
#include <stdlib.h>
#include <string.h>

#include "c_calc.h"

int main(int argc, char** argv) {
    char lenbuf[2];
    int len = 0;
    int status = 0;

    while((status = read(0, lenbuf, 2)) > 0) {
        assert(status == 2);
        len = (lenbuf[0] << 8) + lenbuf[1];
        void *buf = malloc(len);
        assert(buf != NULL);
        process_request(buf, len);
        free(buf);
    }
    return 0;
}

void process_request(void* buf, int len) {
    int i = 0, arity;
    char atombuf[MAXATOMLEN];
    long x, y;
    erlang_pid from_pid;
    erlang_ref from_ref;

    assert(read(0, buf, len) == len);
    assert(ei_decode_version(buf, &i, NULL) == 0);
    assert(ei_decode_tuple_header(buf, &i, &arity) == 0);
    assert(arity == 2);
    assert(ei_decode_tuple_header(buf, &i, &arity) == 0);
    assert(arity == 3);
    assert(ei_decode_atom(buf, &i, atombuf) == 0);
    assert(ei_decode_long(buf, &i, &x) == 0);
    assert(ei_decode_long(buf, &i, &y) == 0);
    assert(ei_decode_tuple_header(buf, &i, &arity) == 0);
    assert(arity == 2);
    assert(ei_decode_pid(buf, &i, &from_pid) == 0);
    assert(ei_decode_ref(buf, &i, &from_ref) == 0);

    ei_x_buff xbuff;
    char lenbuf[2];
    assert(ei_x_new_with_version(&xbuff) == 0);
    assert(ei_x_encode_tuple_header(&xbuff, 2) == 0);

    if(strcmp("add", atombuf) == 0) {
        x += y;
        assert(ei_x_encode_long(&xbuff, x) == 0);
    }
    else if(strcmp("sub", atombuf) == 0) {
        x -= y;
        assert(ei_x_encode_long(&xbuff, x) == 0);
    }
    else if(strcmp("mul", atombuf) == 0) {
        x *= y;
        assert(ei_x_encode_long(&xbuff, x) == 0);
    }
    else if(strcmp("div", atombuf) == 0) {
        x /= y;
        assert(ei_x_encode_long(&xbuff, x) == 0);
    }
    else {
        assert(ei_x_encode_tuple_header(&xbuff, 2) == 0);
        assert(ei_x_encode_atom(&xbuff, "error") == 0);
        assert(ei_x_encode_tuple_header(&xbuff, 2) == 0);
        assert(ei_x_encode_atom(&xbuff, "wrong_op") == 0);
        assert(ei_x_encode_atom(&xbuff, atombuf) == 0);
    }

    assert(ei_x_encode_tuple_header(&xbuff, 2) == 0);
    assert(ei_x_encode_pid(&xbuff, &from_pid) == 0);
    assert(ei_x_encode_ref(&xbuff, &from_ref) == 0);

    int n = xbuff.index;
    lenbuf[0] = (n << 8);
    lenbuf[1] = (n & 0xff);
    assert(write(1, lenbuf, 2) == 2);
    assert(write(1, xbuff.buff, n) == n);
    assert(ei_x_free(&xbuff) == 0);
}
