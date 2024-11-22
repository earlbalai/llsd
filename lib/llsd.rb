require 'rexml/document'
require 'date'

# Class for parsing and generating llsd xml
class LLSD
  class SerializationError < StandardError; end

  LLSD_ELEMENT = 'llsd'

  BOOLEAN_ELEMENT = 'boolean'
  INTEGER_ELEMENT = 'integer'
  REAL_ELEMENT = 'real'
  UUID_ELEMENT = 'uuid'
  STRING_ELEMENT = 'string'
  BINARY_ELEMENT = 'binary'
  DATE_ELEMENT = 'date'
  URI_ELEMENT = 'uri'
  KEY_ELEMENT = 'key'
  UNDEF_ELEMENT = 'undef'

  ARRAY_ELEMENT = 'array'
  MAP_ELEMENT = 'map'

  # PARSING AND ENCODING FUNCTIONS

  def self.to_xml(obj)
    llsd_element = REXML::Element.new LLSD_ELEMENT
    llsd_element.add_element(serialize_ruby_obj(obj))

    doc = REXML::Document.new
    doc << llsd_element
    doc.to_s
  end

  def self.parse(xml_string)
    # turn message into dom element
    doc = REXML::Document.new xml_string

    # get the first element inside the llsd element
    # return parse dom element on first element
    parse_dom_element doc.root.elements[1]
  end

  private

  def self.serialize_ruby_obj(obj)
    # if its a container (hash or map)
    case obj
    when Hash
      map_element = REXML::Element.new(MAP_ELEMENT)
      obj.each do |key, value|
        key_element = REXML::Element.new(KEY_ELEMENT)
        key_element.text = key.to_s
        value_element = serialize_ruby_obj value

        map_element.add_element key_element
        map_element.add_element value_element
      end
      map_element

    when Array
      array_element = REXML::Element.new(ARRAY_ELEMENT)
      obj.each { |o| array_element.add_element(serialize_ruby_obj(o)) }
      array_element

    # Remove Fixnum check since it's deprecated, just use Integer
    when Integer
      integer_element = REXML::Element.new(INTEGER_ELEMENT)
      integer_element.text = obj.to_s
      integer_element

    when TrueClass, FalseClass
      boolean_element = REXML::Element.new(BOOLEAN_ELEMENT)
      boolean_element.text = obj ? 'true' : 'false'
      boolean_element

    when Float
      real_element = REXML::Element.new(REAL_ELEMENT)
      real_element.text = obj.to_s
      real_element

    when Date, DateTime, Time
      date_element = REXML::Element.new(DATE_ELEMENT)
      date_element.text = obj.respond_to?(:strftime) ? 
        obj.strftime('%Y-%m-%dT%H:%M:%SZ') : 
        obj.to_time.strftime('%Y-%m-%dT%H:%M:%SZ')
      date_element

    when String
      if obj.empty?
        REXML::Element.new(STRING_ELEMENT)
      else
        string_element = REXML::Element.new(STRING_ELEMENT)
        string_element.text = obj.to_s
        string_element
      end

    when NilClass
      REXML::Element.new(UNDEF_ELEMENT)

    else
      raise SerializationError, "#{obj.class} cannot be serialized into llsd xml - please serialize into a string first"
    end
  end

  def self.parse_dom_element(element)
    case element.name
    when ARRAY_ELEMENT
      element_value = []
      element.elements.each {|child| element_value << (parse_dom_element child) }
      element_value

    when MAP_ELEMENT
      element_value = {}
      element.elements.each do |child|
        if child.name == 'key'
          element_value[child.text] = parse_dom_element child.next_element
        end
      end
      element_value

    else
      convert_to_native_type(element.name, element.text, element.attributes)
    end
  end

  def self.convert_to_native_type(element_type, unconverted_value, attributes)
    case element_type
    when INTEGER_ELEMENT
      unconverted_value.to_i

    when REAL_ELEMENT
      unconverted_value.to_f

    when BOOLEAN_ELEMENT
      unconverted_value != 'false' && !unconverted_value.nil?

    when STRING_ELEMENT
      unconverted_value || ''

    when DATE_ELEMENT
      if unconverted_value.nil?
        DateTime.strptime('1970-01-01T00:00:00Z')
      else
        DateTime.strptime(unconverted_value)
      end

    when UUID_ELEMENT
      unconverted_value || '00000000-0000-0000-0000-000000000000'

    else
      unconverted_value
    end
  end
end