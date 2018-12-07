#!/usr/bin/sage

#from functools import reduce

#from sage.graphs.tutte_polynomial import edge_multiplicities

import copy

import re

import argparse


s=SymmetricFunctions(QQ).schur()
e=SymmetricFunctions(QQ).e()
X.<x> = InfinitePolynomialRing(QQ, implementation='sparse')

def schurdiv(ss,sa):
    def r(y):
	return reduce(lambda t,e: t+e,map(lambda a:reduce(lambda t,d: t*d,map(lambda c: x[c],a[0]),1)*a[1] , y.monomial_coefficients().items()),0)
    def rq(d):
	return eval(re.sub(r'x_(\d+)(\^(\d+))?',lambda m: '(e['+m.group(1)+']**'+m.group(3)+')' if m.group(2) else 'e['+m.group(1)+']' ,str(d)))
    q,rem=r(e(ss)).polynomial().quo_rem(r(e(sa)).polynomial())
    return (s(rq(q)),s(rq(rem)))

class Tableau:
    
    def __init__(self, n):
	self.tab=[[0 for i in range(n)] for i in range(n)]
	self.deg = n

    def __eq__(self, other):
	return (self.deg==other.deg) and (self.tab==other.tab)

    def __add__(self,other):
	assert(self.deg==other.deg)
	x=Tableau(self.deg)
	for i in range (0, self.deg):
	    for j in range (0, self.deg):
		x.tab[i][j]=self.tab[i][j]+other.tab[i][j]
	return x

    def __sub__(self,other):
	assert(self.deg==other.deg)
	x=Tableau(self.deg)
	for i in range (0, self.deg):
	    for j in range (0, self.deg):
		x.tab[i][j]=self.tab[i][j]-other.tab[i][j]
	return x

    def __neg__(self):
	x=Tableau(self.deg)
	for i in range (0, self.deg):
	    for j in range (0, self.deg):
		x.tab[i][j]=-self.tab[i][j]
	return x

    def __mul__(self,y):
#	assert(i.__class__=='int')
	x=Tableau(self.deg)
	for i in range (0, self.deg):
	    for j in range (0, self.deg):
		x.tab[i][j]=y*self.tab[i][j]
	return x

    def __lt__(self,other):
	assert(self.deg==other.deg)
	return flatten(self.tab) < flatten(other.tab)

    def __lte__(self,other):
	assert(self.deg==other.deg)
	return flatten(self.tab) <= flatten(other.tab)

    def __gt__(self,other):
	assert(self.deg==other.deg)
	return flatten(self.tab) > flatten(other.tab)

    def __le__(self,other):
	assert(self.deg==other.deg)
	return flatten(self.tab) >= flatten(other.tab)

    def positive(self):
	return not( [y for y in flatten(self.tab) if y<0] )

    def __hash__(self):
	return hash(str(self.tab))


    
class Seed:
    Schurcache ={}

    def __init__(self,n, valency=None , vertices=None, graph=None, tabs=None, poly=None, schur=None):
	self.tabs = tabs or {}
	self.schur = schur or {}
        self.poly = poly or {}
        self.signs = {}
        self.graph = graph or {} #graph or DiGraph(multiedges=True)
	self.vertices = vertices or []
        self.deg = n
	self.valency = valency or oo

	if graph==None :
    	    for i in range (0, self.deg):
		for j in range (0, self.deg-i):
#		    self.graph.add_vertex((i,j))
		    self.vertices.append((i,j))

	    for i in range (0,self.deg-1):
		for j in range (0,self.deg-i-1):
		    self.graph[((i,j),(i+1,j))]=1
		    self.graph[((i+1,j),(i,j))]=-1
		    self.graph[((i,j+1),(i,j))]=1
		    self.graph[((i,j),(i,j+1))]=-1
		    self.graph[((i+1,j),(i,j+1))]=1
		    self.graph[((i,j+1),(i+1,j))]=-1
#		    self.graph.add_edge((i,j),(i+1,j))
#		    self.graph.add_edge((i,j+1),(i,j))
#		    self.graph.add_edge((i+1,j),(i,j+1))
	
	if tabs==None :
	    for i in range (0, self.deg):
		for j in range (0, self.deg-i):
		    self.tabs[(i,j)]=Tableau(self.deg)
		    for p in range (0,j+1):
#		    	print i,j,p
			self.tabs[(i,j)].tab[p][p+i]=1

	if schur==None :
	    for i in range (0, self.deg):
		for j in range (0, self.deg-i):
		    partition=[i+1 for k in range(j+1)]
		    self.schur[(i,j)]=s(partition)
		    self.Schurcache[copy.deepcopy(self.tabs[(i,j)])]=self.schur[(i,j)]

	self.signing()
	self.rehash()

    def In(self,vertex):
#	return map(lambda x: x[0:2], x.graph.incoming_edges(vertex))
	return {e: m for e,m in self.graph.items() if e[1]==vertex and m>0}.keys()

    def Out(self,vertex):
#	return map(lambda x: x[0:2], x.graph.outgoing_edges(vertex))
	return {e: m for e,m in self.graph.items() if e[0]==vertex and m>0}.keys()

    def mutable(self):
	return [y for y in self.vertices if y[0]!=0 and y[0]+y[1]<self.deg-1 and len(self.In(y)+self.Out(y))<=self.valency]
#	return [y for y in self.vertices if y[0]!=0 and y[0]+y[1]<self.deg-1]

    def totalsign(self):
	if uniq(self.signs.values())==[1]:
	    return 1
	elif uniq(self.signs.values())==[-1]:
	    retrun -1
	else:
	    return 0

    def sign(self,vertex):
	b1=reduce(lambda a,b : a+self.tabs[b[0]]*self.graph[(b[0],vertex)],self.In(vertex),Tableau(self.deg))
	b2=reduce(lambda a,b : a+self.tabs[b[1]]*self.graph[(vertex,b[1])],self.Out(vertex),Tableau(self.deg))
	if b1==b2:
	    return 0
	elif b1<b2:
	    return -1
	elif b1>b2: 
	    return 1
	else:
	    pass 

    def signing(self):
	self.signs=dict([(v,self.sign(v)) for v in self.mutable()])

    def rehash(self):
	self.hash=hash('|'.join(map(lambda x: str(x), map(lambda x: x.tab, sorted(self.tabs.values())))))

    def mutate(self,vertex):
	
	a=self.tabs[vertex]
	b1=reduce(lambda t,e: t+self.tabs[e[0]]*self.graph[(e[0],vertex)], self.In(vertex),Tableau(self.deg))
	b2=reduce(lambda t,e: t+self.tabs[e[1]]*self.graph[(vertex,e[1])], self.Out(vertex),Tableau(self.deg))

	b=max(b1,b2)-a

	sb=None

	if self.Schurcache.has_key(b):
	    sb=self.Schurcache[b] 
	else:
	    sa=self.schur[vertex]

	    print "*".join(map(lambda e: '('+str(self.schur[e[0]])+')^'+str(self.graph[(e[0],vertex)]), self.In(vertex)))
	    print "+"
	    print "*".join(map(lambda e: '('+str(self.schur[e[1]])+')^'+str(self.graph[(vertex,e[1])]), self.Out(vertex)))
	    print "================"
	    print str(sa)
	    print "="

	    s1=reduce(lambda t,e: t*self.schur[e[0]]^(self.graph[(e[0],vertex)]), self.In(vertex),1)
	    s2=reduce(lambda t,e: t*self.schur[e[1]]^(self.graph[(vertex,e[1])]), self.Out(vertex),1)
	    ss=s1+s2

	    sb,sbre=schurdiv(ss,sa)
	    assert(sbre==0)
	    self.Schurcache[b]=sb
	    print str(sb)
	    print

	z=self.graph.copy()
	a=copy.deepcopy(self.tabs)
	a[vertex]=b
	vv=copy.deepcopy(self.vertices)
	pp=self.poly.copy()
	ss=self.schur.copy()
	ss[vertex]=sb
    
	for i in self.In(vertex):
	    for o in self.Out(vertex):
		z[(i[0],o[1])]=(z[(i[0],o[1])] if z.has_key((i[0],o[1])) else 0) + z[(i[0],vertex)]*z[(vertex,o[1])]
		z[(o[1],i[0])]=-z[(i[0],o[1])]

	for e in self.In(vertex):
	    p=z[e]
	    z[e]=-p
	    z[(e[1],e[0])]=p
	for e in self.Out(vertex):
	    p=z[e]
	    z[e]=-p
	    z[(e[1],e[0])]=p

	
	
	x=Seed(self.deg,self.valency,vv,{e:m for e,m in z.items() if m!=0},a,pp,ss)
	x.signing()
	x.rehash()
	return x


    def __eq__(self,other):
	return (self.deg==other.deg) and (sorted(self.tabs.values()) == sorted(other.tabs.values()) )
	
    def __hash__(self):
	return self.hash
    



#n=args.degree[0]

#Gs=Seed(n)
#St=[]
#St.append([{'g': Gs, 'path': []}])
#Sh={}
#Sh[Gs.hash]=[Gs]

#Tabs=set()
#for v in Gs.mutable():
#    Tabs.add(Gs.tabs[v])
#Schurtabs={}
#for v in Gs.mutable():
#    Schurtabs[Gs.tabs[v]]=Gs.schur[v]    

def Step(n):
    i=1
    
#    St[n+1]=[]
    St.append([])
    for gs in St[n]:
	for v in gs['g'].mutable():
	    path=gs['path']+[v]
	    print path
	    gn=gs['g'].mutate(v)
	    nw=True
	    if Sh.has_key(gn.hash):
		for gg in Sh[gn.hash]:
		    if nw and gg==gn :
			nw=False

	    if nw :
		gx={'g':gn, 'path': path}
		St[n+1].append(gx)
		if Sh.has_key(gn.hash):
		    Sh[gn.hash].append(gn)
		else:
		    Sh[gn.hash]=[gn]
		Tabs.add(gn.tabs[v])
    

