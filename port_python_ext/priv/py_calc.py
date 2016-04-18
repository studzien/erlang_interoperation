#!/usr/bin/env python

import erlport
import sys

def decode_size():
    size = sys.stdin.read(2)
    if size == '':
        exit(0)
    else:
        return int(size.encode('hex'), base=16)

def decode_term(size):
    term = sys.stdin.read(size)
    return erlport.decode(term)

def encode_size(term):
    length = len(term)
    return str(bytearray([length >> 8, length & 0xff]))

def calculate(request):
    ((op, x, y), _)  = request
    f = {'add': lambda x,y: x+y,
         'sub': lambda x,y: x-y,
         'mul': lambda x,y: x*y,
         'div': lambda x,y: x/y}[op]
    return f(x,y)

if __name__ == '__main__':
    while True:
        size = decode_size()
        term = decode_term(size)
        result = calculate(term)
        result_term = erlport.encode(result)
        result_size = encode_size(result_term)
        sys.stdout.write(result_size)
        sys.stdout.write(result_term)
        sys.stdout.flush()
