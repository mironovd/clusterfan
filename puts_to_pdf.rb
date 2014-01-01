#~ require 'pry' # uncomment this and IT'LL EXPLODE! >:(
require 'rubygems'
require 'graphviz'
require 'nokogiri'
require 'prawn'
require 'prawn-svg'


module PDFWriter
  module Digraph
    def self.pos(node_pair)
      "#{node_pair.first}, #{node_pair.last}!"
    end
    private_class_method :pos
    
    def self.jittered_pos(node_pair)
      "#{node_pair.first+rand(-0.2..0.2)}, #{node_pair.last+rand(-0.2..0.2)}!"
    end
    private_class_method :pos
    
    def self.get_svg_size(svg_string)
      svg_node = Nokogiri::XML(svg_string).css('svg').first
      [svg_node[:width].to_f, svg_node[:height].to_f]
    end
    private_class_method :get_svg_size
    
    def self.putz(a_hash_of_edges, width=nil, *marked_node_coordinates)
      nodes = a_hash_of_edges.keys.flatten(1).uniq
      g = GraphViz.new(:G, use: :neato, type: :digraph)
      g[:splines] = :true
      g[:sep] = 4
      g[:overlap] = false
      g.node[shape: :point,]# width: 0.1]
      g.edge[arrowhead: :onormal]
      nodes.each do |node|
        pos = pos(node)
        #~ params = {pos: jittered_pos(node)}
        params = {pos: pos}
        if marked_node_coordinates.include?(node) then
#	  p node.inspect

          params[:shape] = :point
          params[:fixedsize] = true
          params[:label] = ''
	  params[:width]=0.2
	  params[:color]="FF0000"
        end
        g.add_nodes(pos, params)
      end
      a_hash_of_edges.each do |(v1, v2), number_of_edges|
        next if number_of_edges < 0
#        number_of_edges.times do
#	    p pos(v1).inspect+pos(v2).inspect
          g.add_edges(
            pos(v1), pos(v2),
	    {
            :len => Math.sqrt(
              (v1[0]-v2[0])**2+(v1[1]-v2[1])**2
            )*15,
#	    :arrowhead => 'onormal'
	    :label => (number_of_edges>1 ? number_of_edges : '')

	    }
          )
#        end
      end
      width ||= PDFWriter.max_width
      parameters = {width: width}
      svg_string = g.output(svg: String)
#p g.edges.inspect
      w, h = get_svg_size(svg_string)
      resulting_height = width*h/w
      available_height = PDFWriter.pdf.cursor
      if resulting_height > available_height then
        PDFWriter.page_break
      end
      parameters[:at] = [0, PDFWriter.pdf.cursor]
      PDFWriter.pdf.svg(svg_string, parameters)
    end
  end

  def self.start(output_filename=nil)
    @output_filename = output_filename || "pdf_writer.pdf"
    @pdf = Prawn::Document.new(page_size: 'A4')
    begin
      @pdf.font('DejaVuMonoSans.ttf')
    rescue
      @pdf.font('Courier')
    end
  end
  

  def self.font_size(size=12)
    @pdf.font_size(size)
  end

  def self.finish(output_filename=nil)
    @pdf.render_file(output_filename || @output_filename)
  end
  
  def self.putz(*args)
    args.each do |arg| @pdf.text(String(arg)) end
  end
  
  def self.page_break
    @pdf.start_new_page 
  end
  
  def self.max_width
    @pdf.bounds.width
  end
  
  def self.pdf
    @pdf
  end
end

#if $0 == __FILE__ then # usage example
#  PDFWriter.start('puts_to_pdf.test.pdf')
#  
#  PDFWriter.putz("hello world") # no, I _couldn't_ name it `puts`
#  15.times do |i| PDFWriter.putz(i) end
#  PDFWriter.putz("Lorem ipsum\ndolor sit amet")
  
#  graph_example = Marshal.load(IO.read('g.marshal'))
#  PDFWriter::Digraph.putz(graph_example, PDFWriter.max_width/2, [2, 2])
  
#  20.times do |i| PDFWriter.putz(i) end
  
#  PDFWriter.finish
#end
