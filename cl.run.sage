#!/usr/bin/sage

#from functools import reduce

#from sage.graphs.tutte_polynomial import edge_multiplicities

load('cl.lib.sage')

import copy

import re

import argparse

parser=argparse.ArgumentParser(description='Cluster algebra calculations', prog='sage cl.sage')
parser.add_argument('-4', '--degree4', action='store_const', dest='valency', const=4, default=oo, metavar='mutation_degree',
	help='use only degree4 mutable vertices')
parser.add_argument('degree', metavar='deg', type=int, nargs=1,
	help='degree of cluster algebra')

args = parser.parse_args()

#print args.valency
#print args.degree

n=args.degree[0]
xx=true
t=0

Gs=Seed(n, args.valency)
St=[]
St.append([{'g': Gs, 'path': []}])
Sh={}
Sh[Gs.hash]=[Gs]

Tabs=set()
for v in Gs.mutable():
    Tabs.add(Gs.tabs[v])
Schurtabs={}
for v in Gs.mutable():
    Schurtabs[Gs.tabs[v]]=Gs.schur[v]

while xx:
    print "===\nStep: "+str(t)
    print "Number of seeds at step: "+str(len(St[t]))
    print "Total number of seeds at step: "+str(len(flatten(St)))
    print "Tabloids: "+str(len(Tabs))
    
    Step(t)
    if len(St[t+1])==0:
	xx=false
    t+=1

print "===== End ======"
print "Total number of seeds at step: "+str(len(flatten(St)))
print "Tabloids: "+str(len(Tabs))




