require_relative 'puts_to_pdf'

require 'set'
require 'ap'
require 'pp'

require_relative 'seeds'



def pdfp(graph, tedge, tway, deltas)
    PDFWriter.putz("Way: "+tway.inspect)
    PDFWriter::Digraph.putz(graph.edges, PDFWriter.max_width, *tedge)
#    tables=tedge.map{|v| graph.tabs[v]}
    PDFWriter.font_size(10)
#    PDFWriter.pdf.column_box([0, PDFWriter.pdf.cursor], :columns => 3, :width=>PDFWriter.pdf.bounds.width) do
#        tedge.each{|v|
#		PDFWriter.pdf.text("Vertex: "+v.inspect)
#		PDFWriter.pdf.text(graph.tabs[v].to_str)
#	}

    t=PDFWriter.pdf.make_table(tedge.map{|v|
	["Vertex :"+v.inspect+"\n"+graph.tabs[v].to_str, "\n"+deltas[v].to_str]})

    t.draw
	
    
    PDFWriter.page_break
    PDFWriter.font_size(8)
    PDFWriter.putz("Graph matrix:")
    PDFWriter.pdf.column_box([0, PDFWriter.pdf.cursor], :columns => 3, :width=>PDFWriter.pdf.bounds.width) do
	PDFWriter.pdf.text(graph.edges.select{|v,k| k>0}.pretty_inspect)#ai(:plain=>true))
    end    
    p graph.edges.select{|v,k| k>0}.inspect
    p tedge.inspect
#    PDFWriter.putz(graph.edges.ai(:plain=>true))
    PDFWriter.font_size
    PDFWriter.page_break

end


def pdfpway(graph, tv, tway)
    PDFWriter.putz("Way: "+tway.inspect)
    PDFWriter::Digraph.putz(graph.edges, PDFWriter.max_width, *tv)
#    tables=tedge.map{|v| graph.tabs[v]}
    PDFWriter.font_size(10)
#    PDFWriter.pdf.column_box([0, PDFWriter.pdf.cursor], :columns => 3, :width=>PDFWriter.pdf.bounds.width) do
#        tedge.each{|v|
#		PDFWriter.pdf.text("Vertex: "+v.inspect)
#		PDFWriter.pdf.text(graph.tabs[v].to_str)
#	}

    t=PDFWriter.pdf.make_table(tv.map{|v|
	["Vertex :"+v.inspect+"\n"+graph.tabs[v].to_str]})

    t.draw
	
    
    PDFWriter.page_break
    PDFWriter.font_size(8)
    PDFWriter.putz("Graph matrix:")
    PDFWriter.pdf.column_box([0, PDFWriter.pdf.cursor], :columns => 3, :width=>PDFWriter.pdf.bounds.width) do
	PDFWriter.pdf.text(graph.edges.select{|v,k| k>0}.ai(:plain=>true))
    end    
    p graph.edges.select{|v,k| k>0}.inspect
    p tv.inspect
#    PDFWriter.putz(graph.edges.ai(:plain=>true))
    PDFWriter.font_size
    PDFWriter.page_break

end


def pway(g,e,way)
    ww=[]
    deltas={}
    e.each{|v| deltas[v]=''}

    pdfp(g,e,ww,deltas)
    way.each{|v|
	ww.push(v)
	g=g.mutate(v)
	pdfpway(g,[v],ww)
    }
end


p ARGV

gs=Graph.new(ARGV[0].to_i)

$prefix="cl."+ARGV[0]+".res"#ARGV[1]

#way=[[1, 1], [1, 2], [2, 0], [1, 1], [2, 2], [3, 0]]
way=[]
eval("way = " + ARGV[1])
p way
edges=[]
eval("edges = " + ARGV[2])
p edges


gs=way.reduce(gs){|g,x| g.mutate(x)}

#edges=gs.edges.find_all{|e| e[1]>1}
#p edges.inspect
#if edges.size>1 then
#    die "More than one multiple edge"
#end

edge=edges[0][0].reverse
puts edge.inspect
if not ((edge[0][0]+edge[0][1]<ARGV[0].to_i-1) and (edge[0][0]!=0) and (edge[1][0]+edge[1][1]<ARGV[0].to_i-1) and edge[1][0]!=0) then exit 0 end
M=[gs]

deltas=Hash.new
old=Hash.new
edge.each{|v| old[v]=gs.tabs[v]}

system('rm puts_to_pdf.test.pdf')
PDFWriter.start('puts_to_pdf.test.pdf')


pway(Graph.new(ARGV[0].to_i),edge,way)

k=2

(0..3).each{|i|
    edge.each{|v|
	gs=gs.mutate(v)
	edge.each{|v| deltas[v]=gs.tabs[v]-old[v]; old[v]=gs.tabs[v]}
	M.push(gs)
	way.push(v)
	pdfp(gs,edge,way,deltas)
	s=gs.edges.find_all{|e| e[1]>k}.find_all{|e| (e[0][0][0]+e[0][0][1]<ARGV[0].to_i-1) and (e[0][1][0]+e[0][1][1]<ARGV[0].to_i-1) and (e[0][0][0]!=0) and (e[0][1][0]!=0)}
	k=(s.map{|e| e[1]}.max ? s.map{|e| e[1]}.max : k)
	puts "F \""+way.inspect+"\" \""+s.inspect+"\ \n"+k.to_s+"\n"
    }
}


PDFWriter.finish
#puts M.inspect

