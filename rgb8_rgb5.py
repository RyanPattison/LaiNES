#!/usr/bin/env python

import sys
fname = sys.argv[1]


def torgb5(v):
	r = (v >> 16) & 0xFF
	g = (v >> 8) & 0xFF
	b = (v >> 0) & 0xFF
	low = ((g << 3) & 0xC0) | (b >> 2) | 1
	high = (r & 0xF8) | (g >> 5)
	return (high << 8) | low


with open(fname, 'r') as f:
	words = [word for line in f  for word in line.split() ]
	data = map(torgb5, map(lambda x: int(x, 16), words))
	print ' u16 nesRgb[] =\n { ' 
	print ', '.join(map(lambda x: '0x%04X' % x, data))
	print '};' 
