# typed: true

class Faraday::Request
  sig { returns(Symbol) }
  attr_accessor :http_method

  sig { returns(T.any(URI, String)) }
  attr_accessor :path

  sig { returns(T::Hash[T.untyped, T.untyped]) }
  attr_accessor :params

  sig { returns(Faraday::Utils::Headers) }
  attr_accessor :headers

  sig { returns(T.untyped) }
  attr_accessor :body

  sig { returns(Faraday::RequestOptions) }
  attr_accessor :options
end
