module RDF::XML
  ##
  # XML format specification.
  #
  # @example Obtaining an XML format class
  #   RDF::Format.for(:xml)         #=> RDF::XML::Format
  #   RDF::Format.for("etc/doap.xml")
  #   RDF::Format.for(:file_name      => "etc/doap.xml")
  #   RDF::Format.for(:file_extension => "xml")
  #   RDF::Format.for(:content_type   => "application/rdf+xml")
  #
  class Format < RDF::Format
    content_type     'application/rdf+xml', :extension => :xml
    content_encoding 'utf-8'

    reader { RDF::XML::Reader }
    writer { RDF::XML::Writer }

  end # class Format
end # module RDF::XML
