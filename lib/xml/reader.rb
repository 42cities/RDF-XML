module RDF
  module XML
    class Reader < RDF::Reader

      format RDF::XML::Format

      ##
      # [-]
      ##
      def initialize(input = $stdin, options = {}, &block)
        @input = input.respond_to?(:read) ? input.read : input
        @xml = ::Nokogiri::XML(@input)
        yield self if block_given?
      end

      ##
      # [-]
      ##
      def each_triple(&block)
        return unless block_given?
        if @xml.root.nil?
          raise RuntimeError, 'Malformed XML document'
        end
        @xml.root.subnodes.each do |node|
          parse_descriptions(node, &block)
        end
      end

      ##
      # [-]
      ##
      def each_statement(&block)
        return unless block_given?
        each_triple do |*triple|
          yield RDF::Statement.new(*triple)
        end
      end

      private

      ##
      # [-]
      ##
      def parse_descriptions(element, parent = nil, predicate = nil, &block)
        
        # Parsing all inline properties
        properties = Hash[parse_inline_properties(element)]
        # Checking if this is a blank node
        uri = properties.key?(:uri) ? properties.delete(:uri) : RDF::Node.uuid

        # If parent is present, yield the relationship
        unless parent.nil?
          block.call([parent, predicate, uri])
        end

        # Yield each nested property
        properties.each do |name, value|
          block.call([uri, name, value])
        end
        
        # Yield RDF type, if tag name is not RDF.description
        if element.ns_name != RDF.Description
          block.call([uri, RDF.type, element.ns_name])
        end
        
        parse_all_nested_properties(element, uri, &block)
      end

      ##
      # [-]
      ##
      def parse_all_nested_properties(element, parent, &block)
        element.subnodes.each do |node|
          parse_nested_property(node, parent, &block)
        end
      end
      
      ##
      # [-]
      ##
      def property_has_node_id?(element)
        att = element.attribute_with_ns('nodeID', RDF.to_uri.to_s)
        att.nil? ? nil : RDF::Node.new(att.value)
      end
      
      ##
      # [-]
      ##
      def property_has_resource?(element)
        att = element.attribute_with_ns('resource', RDF.to_uri.to_s)
        att.nil? ? nil : RDF::URI.new(element.base || uri).join(att.value)
      end
      
  		# Checks if rdf:parseType is set to 'Resource'
  		# <ex:editor rdf:parseType="Resource">
	    #   <ex:fullName>Dave Beckett</ex:fullName>
	    #   <ex:homePage rdf:resource="http://purl.org/net/dajobe/"/>
	    # </ex:editor>
      def property_is_resource_parse_type?(element, parent, &block)
        att = element.attribute_with_ns('parseType', RDF.to_uri.to_s)
        object = att.nil? ? nil : (att.value == 'Resource' ? RDF::Node.uuid : nil)
        return nil if object.nil?
        parse_all_nested_properties(element, object, &block)
        block.call([parent, element.ns_name, object])
        true
      end
      
      ##
      # [-]
      ##
      def property_is_resource?(element, parent, &block)
        object = (property_has_node_id?(element) or property_has_resource?(element))
        return nil if object.nil?
        block.call([parent, element.ns_name, object])
        true
      end
      
  		# Checks if rdf:parseType is set to 'Literal'
  		# <ex:editor rdf:parseType="Literal">
	    #   <html><head><title>Hello, world!</title></head></html>
	    # </ex:editor>
      def property_is_literal_parse_type?(element, parent, &block)
        att = element.attribute_with_ns('parseType', RDF.to_uri.to_s)
        object = att.nil? ? nil : (att.value == 'Literal' ? true : nil)
        return nil if object.nil?
        block.call([parent, element.ns_name, element.to_s])
        true
      end
      
      ##
      # [-]
      ##
      def property_has_subnodes?(element, parent, &block)
        return nil if element.subnodes.empty?
        element.subnodes.each do |child|
          parse_descriptions(child, parent, element.ns_name, &block)
        end
      end
      
      ##
      # [-]
      ##
      def parse_nested_property(element, parent, &block)
        return if property_is_resource?(element, parent, &block)
        return if property_is_resource_parse_type?(element, parent, &block)
        return if property_is_literal_parse_type?(element, parent, &block)
        return if property_has_subnodes?(element, parent, &block)

    		# Checks if property has xml:lang
        att = element.attribute_with_ns('lang', 'http://www.w3.org/XML/1998/namespacelang')
        language = (att.nil? ? nil : att.value)
        
    		# Checks if property has rdf:datatype
        att = element.attribute_with_ns('datatype', RDF.to_uri.to_s)
        datatype = (att.nil? ? nil : att.value)
        
        object = RDF::Literal.new(element.content, {
          :datatype => datatype,
          :language => language })

        block.call([parent, element.ns_name, object])

      end

      ##
      # [-]
      ##
      def parse_inline_properties(element)
        element.attributes.values.map do |att|
          case att.ns_name
            when RDF.about    then [:uri, RDF::URI.new(element.base || uri).join(att.value)]
            when RDF.ID       then [:uri, RDF::URI.new(element.base || att.value).join(att.value)]
            when RDF.nodeID   then [:uri, RDF::Node.new(att.value)]
            else [att.ns_name, att.value]
          end
        end
      end
      
    end # Reader
  end # XML
end # RDF


module Nokogiri
  module Common
    def ns_name
      RDF::URI.new((namespace.nil? ? '' : namespace.href) + name)
    end
  end
  module XML
    class Attr
      include Nokogiri::Common
    end
    class Element
      include Nokogiri::Common
      def base
        att = document.root.attributes['base']
        att.nil? ? '' : att.value
      end
      def subnodes
        children.reject { |child| child.text? }
      end
    end
  end
end