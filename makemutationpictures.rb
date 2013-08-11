require_relative 'puts_to_pdf'

require 'set'
require 'ap'

require_relative 'seeds'



def pdfp(graph, tedge, tway)
    PDFWriter.putz("Way: "+tway.inspect)
    PDFWriter::Digraph.putz(graph.edges, PDFWriter.max_width, *tedge)
#    tables=tedge.map{|v| graph.tabs[v]}
    PDFWriter.font_size(10)
    tedge.each{|v|
	PDFWriter.putz("Vertex: "+v.inspect)
	PDFWriter.putz(graph.tabs[v].to_str)
    }
    PDFWriter.page_break
    PDFWriter.font_size(8)
    PDFWriter.putz("Graph matrix:")
    PDFWriter.pdf.column_box([0, PDFWriter.pdf.cursor], :columns => 3, :width=>PDFWriter.pdf.bounds.width) do
	PDFWriter.pdf.text(graph.edges.select{|v,k| k>0}.inspect)#(:plain=>true))
    end    
    p graph.edges.select{|v,k| k>0}.inspect
    p tedge.inspect
#    PDFWriter.putz(graph.edges.ai(:plain=>true))
    PDFWriter.font_size
    PDFWriter.page_break

end

def pway(g,e,way)
    ww=[]
    pdfp(g,e,ww)
    way.each{|v|
	ww.push(v)
	g=g.mutate(v)
	pdfp(g,e,ww)
    }
end

PDFWriter.start('puts_to_pdf.test.pdf')

gs=Graph.new(ARGV[0].to_i)

$prefix="cl."+ARGV[0]+".res"#ARGV[1]

way=[[1, 0], [2, 1], [1, 1], [2, 0], [3, 1], [3, 2]]

gs=way.reduce(gs){|g,x| g.mutate(x)}

edges=gs.edges.find_all{|e| e[1]>1}
p edges.inspect
if edges.size>1 then
    die "More than one multiple edge"
end

edge=edges[0][0]
puts edge.inspect
M=[gs]

pway(Graph.new(ARGV[0].to_i),edge,way)

(0..10).each{|i|
    edge.each{|v|
	gs=gs.mutate(v)
	M.push(gs)
	way.push(v)
	pdfp(gs,edge,way)
    }
}


PDFWriter.finish
#puts M.inspect

