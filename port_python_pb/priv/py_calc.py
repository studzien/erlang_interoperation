#!/usr/bin/env python

import calc_pb2
import sys

def decode_size():
    size = sys.stdin.read(2)
    if size == '':
        exit(0)
    else:
        return int(size.encode('hex'), base=16)

def encode_size(term):
    length = len(term)
    return str(bytearray([length >> 8, length & 0xff]))

def calculate(calc):
    f = {calc_pb2.Calculation.add: lambda x,y: x+y,
         calc_pb2.Calculation.sub: lambda x,y: x-y,
         calc_pb2.Calculation.mul: lambda x,y: x*y,
         calc_pb2.Calculation.div: lambda x,y: x/y}[calc.operation]
    return f(calc.arg1, calc.arg2)

if __name__ == '__main__':
    while True:
        size = decode_size()
        calculation = calc_pb2.Calculation()
        calculation.ParseFromString(sys.stdin.read(size))

        result = calc_pb2.Result()
        result.result = calculate(calculation)
        result_serialized = result.SerializeToString()
        result_size = encode_size(result_serialized)

        sys.stdout.write(result_size)
        sys.stdout.write(result_serialized)
        sys.stdout.flush()
