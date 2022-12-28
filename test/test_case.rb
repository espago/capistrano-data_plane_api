# frozen_string_literal: true

class TestCase < ::Minitest::Test
  # Name of the current test.
  #
  # @return [String]
  def name_of_test
    name.to_s.delete_prefix("test_: #{tested_class_name} ").delete_suffix('. ')
  end

  # @return [String]
  def tested_class_name
    self.class.name.delete_suffix('Test')
  end

  # @return [String]
  def cassette_name
    [
      *class_module_path(self),
      name_of_test
    ].map { |el| to_snakecase(el) }
      .join('/')
  end

  # Returns an array containing constants under which the passed class (or instance of it) has been defined.
  #
  #     class_module_path(SomeClass::In::Modules.new) #=> ['SomeClass', 'In', 'Modules']
  #
  # @param object [Object]
  # @return [Array<String>]
  def class_module_path(object)
    klass = object.is_a?(::Class) ? object : object.class
    klass.to_s.split('::')
  end

  # Converts a string in PascalCase or camelCase to snake_case.
  #
  #     to_snakecase('SomePascalCase') => "some_pascal_case"
  #
  # @param string [String]
  # @return [String]
  def to_snakecase(string)
    string.gsub(/([^A-Z])([A-Z]+)/, '\1_\2').downcase
  end

  # Wraps around `VCR.use_cassette` with an automatically generated cassette name using the `cassette_name` method
  #
  # @param options [Hash] options which will be passed to `VCR.use_cassette`
  # @return [void]
  def http_cassette(options = {}, &block)
    ::VCR.use_cassette(cassette_name, options, &block)
  end
end
