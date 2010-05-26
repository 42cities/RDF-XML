module RDF
  ##
  # **`RDF::XML`** is an XML plugin for RDF.rb.
  #
  # @example Requiring the `RDF::XML` module
  #   require 'rdf-xml'
  #
  # @example Parsing RDF statements from an XML file
  #   RDF::XML::Reader.open("etc/doap.xml") do |reader|
  #     reader.each_statement do |statement|
  #       puts statement.inspect
  #     end
  #   end
  #
  # @example Serializing RDF statements into an XML file
  #   RDF::XML::Writer.open("etc/test.xml") do |writer|
  #     reader.each_statement do |statement|
  #       writer << statement
  #     end
  #   end
  #
  # @see http://rdf.rubyforge.org/
  #
  # @author [Alex Serebryakov](http://42cities.com/)
  module XML
    require 'rdf'
    require 'xml/format'
    require 'nokogiri'
    
    autoload :Reader,  'xml/reader'
    autoload :Writer,  'xml/writer'
    autoload :VERSION, 'xml/version'
  end # module XML
end # module RDF
