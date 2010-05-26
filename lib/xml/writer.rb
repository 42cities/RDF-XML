module RDF
  module XML
    class Writer < RDF::Writer

      format RDF::XML::Format

      ##
      # [-]
      ##
      def initialize(output = $stdout, options = {}, &block)
        @output, @options = output, options
        @nodes = {}
        @base = nil
        @namespaces = { :rdf => RDF.to_uri.to_s }
        
        if block_given?
          yield self
          write_prologue unless @options[:declaration] == false
          write_document
          write_epilogue unless @options[:declaration] == false
        end
      end
      
      ##
      # [-]
      ##
      def write_prologue
        
        ns = @namespaces.map do |short, uri|
          ' xmlns:%s="%s"' % [short, uri]
        end.join('')
        
        unless @base.nil?
          bs = ' xml:base="%s"' % @base
        end
        
        puts ("<?xml version='1.0' encoding='utf-8'?><rdf:RDF %s %s>" % [ns, bs], false)
      end
      
      def write_epilogue
        puts "</rdf:RDF>"
      end

      ##
      # [-]
      ##
      def write_document
        @nodes.each do |id, atts|
          puts format_description(id, atts)
        end
      end

      ##
      # [-]
      ##
      def write_triple(subject, predicate, object)
        s = subject.to_s
        p = predicate.to_s
        @nodes[s]    ||= {}
        @nodes[s][p] ||= []
        @nodes[s][p] << object
      end
      
      ##
      # [-]
      ##
      def namespace!(uri, short)
        @namespaces[short.to_s.to_sym] = uri.to_s
      end
      
      ##
      # [-]
      ##
      def base!(uri)
        @base = uri.to_s
      end
      
      private

      
      ##
      # [-]
      ##
      def format_description(id, atts)
        tag       = format_tag_name(atts)
        contents  = format_attributes(atts)
        about     = ' rdf:about="%s"' % id
        "<%s%s>%s</%s>" % [tag, about, contents, tag]
      end
      
      ##
      # [-]
      ##
      def format_tag_name(atts)
        if atts.key?(RDF.type.to_s)
          atts.delete(RDF.type.to_s).first
        else
          "rdf:Description"
        end
      end
      
      ##
      # [-]
      ##
      def format_attributes(atts)
        atts.map do |predicate, values|
          values.map do |value|
            format_attribute(predicate, value)
          end.join('')
        end.join('')
      end
      
      ##
      # [-]
      ##
      def format_attribute(predicate, value)
        if value.kind_of? RDF::Resource
          format_resource_att(predicate, value)
        elsif value.kind_of? Literal
          format_literal_att(predicate, value)
        end
      end
      
      ##
      # [-]
      ##
      def format_resource_att(predicate, value)
        '<%s rdf:resource="%s" />' % [predicate, value.to_s]
      end

      ##
      # [-]
      ##
      def format_literal_att(predicate, value)
        extra = ""
        if value.has_datatype?
          extra += ' rdf:datatype="%s"' % value.datatype.to_s
        end
        if value.has_language?
          extra += ' xml:lang="%s"' % value.language.to_s
        end
        if value.kind_of? RDF::Literal
          value = value.object
        end
        '<%s%s>%s</%s>' % [predicate, extra, value, predicate]
      end
      
      ##
      # [-]
      ##
      def adjust_ns(string)
        @namespaces.each do |short, uri|
          string = string.gsub(uri, "%s:" % short)
        end
        string
      end
      
      ##
      # [-]
      ##
      def adjust_base(string)
        unless @base.nil?
          string = string.gsub(@base, '')
        end
        string
      end
      
      ##
      # [-]
      ##
      def puts(string, adjust = true)
        if adjust
          string = adjust_ns(string)
          string = adjust_base(string)
        end
        @output.puts(string)
      end
      
    end # Writer
  end # XML
end # RDF
