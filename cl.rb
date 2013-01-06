#require 'rubygems'
#require 'awesome_print'
require 'set'

require_relative 'seeds'

Gs=Graph.new(ARGV[0].to_i)

$prefix="cl."+ARGV[0]+".res"#ARGV[1]

`rm -fr #{$prefix}.neggr`
Dir.mkdir($prefix+".neggr")

#puts Gs.mutable.inspect

St=Array.new
Sh=Hash.new
#As=Hash.new
St[0]=[{:g=>Gs, :path=>[]}]
Sh[Gs.hash]=[Gs]

Tabs=Set.new

Gs.mutable.each{|v| Tabs.add(Gs.tabs[v])}

def Step(n)
    i=1
#    As[n+1]=[]
    St[n+1]=[]
    (St[n]).each{|r|
	r[:g].mutable.each{|v|
#	    puts v.inspect
#	    puts "================"
	    g=r[:g].mutate(v);
#	    puts g.inspect
	    nw=true
#	    (0..n).each{|nn| (0..St[nn].size-1).each{|u| 
#		gg=St[nn][u]
#		puts gg.inspect
#	    (0..n+1).each_with_index{|nn,u| St[nn].each{|gg| 
#
#		if nw and gg[:g]==g then
#		    nw=false
#		    As[[i,v]]={:s=>nn,:n=>u}
#		    #[n+1].push({:g=>i, :v => v, :gt=>[nn,u]})
#		end
#	    }}

	    if Sh[g.hash] then
		Sh[g.hash].each{|gg|
		    if nw and gg==g then
			nw = false
		    end
		}
	    end

	    if nw then
		gx={:g=>g,:path=>r[:path]+[v]}
		St[n+1].push(gx)
		if Sh[g.hash] then
		    Sh[g.hash].push(g)
		else
		    Sh[g.hash]=[g]
		end
		
		if Tabs.add?(gx[:g].tabs[v])
		    File.open($prefix+".tabs","wb"){|f| Tabs.to_a.sort.each{|t| f.write(t.to_str+"\n")}}
		end
		if not gx[:g].tabs[v].positive? then
		   puts "FOUND NEGATIVE:\n"+(gx.inspect)
		    File.write($prefix+".neggr/"+"graph"+gx[:g].deg.to_s+"."+gx[:g].hash.to_s+".marshal", Marshal.dump(gx))
		    $stdout.flush 
		end 		

		if (not r[:g].edges.find{|e| e[1]>1}) and g.edges.find{|e| e[1]>1} then
		    puts "FOUND NEW MULTIPLE:\n"
		    puts gx[:path].inspect+"\n"
		    puts g.edges.find_all{|e| e[1]>1}.map{|u| u[0]}.inspect
		    $stdout.flush 		    
		end
	    end	
	}
	i+=1
    }
#    puts St[n+1].inspect    
end

xx=true

t=0
while xx do
    puts "===\nStep: "+t.to_s
    puts "Number of seeds at step: "+St[t].size.to_s
    puts "Total number of seeds at step: "+St.flatten.size.to_s
    puts "Tabloids: "+Tabs.size.to_s
    $stdout.flush 
#    Tabs.sort.each{|x|puts x.inspect}
    Step(t)    
    if St[t+1]==[] then xx=false end
    t+=1
end


#puts St.inspect
#puts As.inspect

puts St.flatten.length
puts Tabs.length
