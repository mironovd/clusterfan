#!/usr/bin/ruby
require 'pry'
require 'pty'
require 'expect'

ans=[]

File.readlines('answers').each{|line|
    x=line.split(/\s*\+\s*/)
    y=x.map{|a|  
	a.match(/s\[(.*)\]/){|m| m[1].split(/\s*,\s*/) }.map{|r| r.to_i}
    }
    ans.push([line,y])
}

ans.each{|r|
    mx=r[1].map{|s| s.length}.max
    r[1].each{|s|
	if s.length<mx then (1..mx-s.length).each{ s.push(0)} end
    }
}

ans=ans.sort{|a,b| a[1].length<=>b[1].length}

binding.pry

PTY.spawn("/usr/bin/polymake") do |input, output, pid|
print pid
#output.expect(' >')
#input.sync = true
#output.sync = true
i=0
ans.each{|r| q=r[1]
    print "===============\n", "CASE ", i+1; puts
    input.expect(/ >/)
    puts r[0]
#    puts "$p=new Polytope(POINTS=>"+q.map{|r| [1]+r}.to_s+");"
    output.puts "$p=new Polytope(POINTS=>"+q.map{|r| [1]+r}.to_s+");\n"
    input.expect(/ >/)
#    input.expect(/ >/)

    output.puts "print $p->VERTICES;\n"
    input.expect(/ >/)
    if i>0 then   input.expect(/ >/) end
#    output.puts "print $p->N_BOUNDARY_LATTICE_POINTS;"
#    input.expect(/ >/)
    output.puts "print $p->N_VERTICES;"
    input.gets
    res=input.gets
    res
    vert_n=res.to_i
    print "VERT ",  vert_n ; puts
    input.expect(/ >/)
    output.puts "print $p->N_INTERIOR_LATTICE_POINTS;"
    input.gets
    res=input.gets
    res
    int_n=res.to_i
    print "INT ",  int_n ; puts
    input.expect(/ >/)
    output.puts "print $p->N_BOUNDARY_LATTICE_POINTS;"
    input.gets
    res=input.gets
    input.expect(/ >/)[0]
    res
    bou_n=res.to_i
    print "BOU ", bou_n ; puts
    
    if int_n==0 and bou_n==q.length then
	puts "OK"
    elsif int_n+bow_n=q.length then
	puts "OK WITH INT POINTS"
    else 
	puts "NOT OK"
    end
    if vert_n==q.length then
	puts "VERT ALL"
    else 
	puts "VERT LOWER"
    end
    
    output.puts "\n"    
    input.expect(/ >/)
    output.puts "\n"    
    
    
    output.puts "\n"
    i+=1
}

end

binding.pry

print