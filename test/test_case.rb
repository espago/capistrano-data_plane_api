# typed: true
# frozen_string_literal: true

class TestCase < ::Minitest::Test
  # Name of the current test.
  #
  #: -> String
  def name_of_test
    name.to_s.delete_prefix("test_: #{tested_class_name} ").delete_suffix('. ')
  end

  #: -> String
  def tested_class_name
    T.must self.class.name&.delete_suffix('Test')
  end

  #: -> String
  def cassette_name
    [
      *class_module_path(self),
      name_of_test,
    ].map { |el| to_snakecase(el) }
      .join('/')
  end

  # Returns an array containing constants under which the passed class (or instance of it) has been defined.
  #
  #     class_module_path(SomeClass::In::Modules.new) #=> ['SomeClass', 'In', 'Modules']
  #
  #: (Object) -> Array[String]
  def class_module_path(object)
    klass = object.is_a?(::Class) ? object : object.class
    klass.to_s.split('::')
  end

  # Converts a string in PascalCase or camelCase to snake_case.
  #
  #     to_snakecase('SomePascalCase') => "some_pascal_case"
  #
  #: (String) -> String
  def to_snakecase(string)
    string.gsub(/([^A-Z])([A-Z]+)/, '\1_\2').downcase
  end

  # Wraps around `VCR.use_cassette` with an automatically generated cassette name using the `cassette_name` method
  #
  # @param options: options which will be passed to `VCR.use_cassette`
  #: [R] (Hash[Symbol, untyped]) { -> R } -> R
  def http_cassette(options = {}, &)
    ::VCR.use_cassette(cassette_name, options, &)
  end
end
