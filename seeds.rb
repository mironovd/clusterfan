
def dc4(value)
  if value.is_a?(Hash)
    result = value.clone
    value.each{|k, v| result[k] = dc4(v)}
    result
  elsif value.is_a?(Array)
    result = value.clone
    result.clear
    value.each{|v| result << dc4(v)}
    result
  else
    value
  end
end


class Tableau
    attr_accessor :deg
    attr_accessor :tab

    def initialize n
  @deg=n
	@tab=[]
	(0..(n-1)).each{|i| @tab[i]=[]}
	(0..(n-1)).each{|i| (0..(n-1)).each{|j| @tab[i][j]=0 }}
    end

    def == other
	(self.deg==other.deg) and (self.tab==other.tab)
    end

    def + other
	x=Tableau.new(self.deg)
	(0..(@deg-1)).each{|i| (0..(@deg-1)).each{|j| x.tab[i][j]=self.tab[i][j]+other.tab[i][j]}}
	return x
    end

    def - other
	x=Tableau.new(self.deg)
	(0..(@deg-1)).each{|i| (0..(@deg-1)).each{|j| x.tab[i][j]=self.tab[i][j]-other.tab[i][j]}}
	return x
    end

    def -@
	x=Tableau.new(self.deg)
	(0..(@deg-1)).each{|i| (0..(@deg-1)).each{|j| x.tab[i][j]=-self.tab[i][j]}}
	return x
    end	

    def * int
	x=Tableau.new(self.deg)
	(0..(@deg-1)).each{|i| (0..(@deg-1)).each{|j| x.tab[i][j]=self.tab[i][j]*int}}
	return x
    end

    def <=> other
	return self.tab.flatten <=> other.tab.flatten
    end

    def eql? other
	return self == other
    end

    def positive?
	return (not (self.tab.flatten.find{|i| i<0}))
    end
    
    def hash
	return self.tab.hash
    end

    def to_str
	return self.tab.reverse.inject(""){|s,r| s+"|"+r.each{|e| sprintf("% 4d",e)}.join(" ")+"|\n"}
    end

end

class Graph 
    attr_accessor :edges
    attr_accessor :vertices
    attr_accessor :deg
    attr_accessor :tabs

    attr_accessor :hash

    def initialize n
	@edges=Hash.new
	@vertices=Array.new
	@tabs=Hash.new
	(0..(n-1)).each{|i| (0..(n-i-1)).each{|j| @vertices.push([i,j])}}
	(0..(n-2)).each{|i| (0..(n-i-2)).each{|j| @edges[[[i,j],[i+1,j]]]=1; @edges[[[i+1,j],[i,j]]]=-1;
			@edges[[[i,j+1],[i,j]]]=1; @edges[[[i,j],[i,j+1]]]=-1;
			@edges[[[i+1,j],[i,j+1]]]=1; @edges[[[i,j+1],[i+1,j]]]=-1;
	}}
	(0..(n-1)).each{|i| (0..(n-i-1)).each{|j| 
		    x=Tableau.new(n)
		    (0..j).each{|p| x.tab[p][p+i]=1}
		    @tabs[[i,j]]=x
#		    puts @tabs[[i,j]]
	}}
	@deg=n
	rehash
    end

    def mutable
	@vertices.find_all{|e| e[0]!=0 and e[0]+e[1]<@deg-1}
    end

    def In vertex
	@edges.keys.find_all{|k| @edges[k]>0}.find_all{|k| k[1]==vertex}
    end

    def Out vertex
	@edges.keys.find_all{|k| @edges[k]>0}.find_all{|k| k[0]==vertex}
    end

    def mutate vertex
#	x=dc4(self)
	z=dc4(@edges)

#	ap self.inspect
#	ap In(vertex).inspect
#	ap Out(vertex).inspect

	a=@tabs[vertex]
	b1=In(vertex).reduce(Tableau.new(@deg)){|t, e| 
#	    puts e.inspect, @tabs[e[0]].inspect; 
	    t+=@tabs[e[0]]*@edges[[e[0],vertex]]}
	b2=Out(vertex).reduce(Tableau.new(@deg)){|t, e| t+=@tabs[e[1]]*@edges[[vertex,e[1]]]}
	b=[b1,b2].max-a

	In(vertex).each{|i| Out(vertex).each{|o|
	    z[[i[0],o[1]]]=(z[[i[0],o[1]]] ? z[[i[0],o[1]]] : 0)+z[[i[0], vertex]] * z[[vertex,o[1]]]
	    z[[o[1],i[0]]]=-z[[i[0],o[1]]]
	}}
	(In(vertex)+Out(vertex)).each{|e| p=z[e]; z[e]=-p; z[e.reverse]=p;}
	x=Graph.new(@deg)
	x.edges=z.reject{|k,v| v==0}
	x.tabs=dc4(@tabs)
	x.tabs[vertex]=b
	x.rehash
	return x
    end

    def rehash
	@hash=self.mutable.inject([]){|a,v| a.push(self.tabs[v])}.sort.inject([]){|a,t| a.push(t.hash)}.hash
    end

    def == (other)
#	return (self.deg==other.deg and self.vertices==other.vertices and self.edges==other.edges)		
	(self.deg==other.deg) and self.hash==other.hash and self.mutable.inject([]){|a,v| a.push(self.tabs[v])}.sort==other.mutable.inject([]){|a,v| a.push(other.tabs[v])}.sort
#	(self.deg==other.deg) and self.tabs.values.sort == other.tabs.values.sort
    end

	

end

#return 0
