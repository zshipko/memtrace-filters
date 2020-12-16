import argparse
import sys

def lines(f):
    if f == '-':
        f = sys.stdin
    if type(f) == str:
        f = open(f)
    return [line[:-1] for line in f.readlines()]

def args(title, init = None):
    parser = argparse.ArgumentParser(title)
    parser.add_argument('--input', '-i', default='-', help='input path or "-" for stdin')
    parser.add_argument('--output', '-o', default='-', help='output path or "-" to display the graph in a window')
    parser.add_argument('--logs', default=None, help='irmin-pack benchmark log output (with stats enabled)')
    if init is not None:
        init(parser)
    return parser.parse_args()

