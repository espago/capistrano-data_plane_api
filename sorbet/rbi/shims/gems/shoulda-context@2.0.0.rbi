# typed: true

class Minitest::Test
  class << self
    def context(name, &blk); end
    sig do
      params(
        name_or_matcher: String,
        options: T.untyped,
        blk: T.proc.bind(T.attached_class).void
      ).void
    end
    def should(name_or_matcher, options = T.unsafe(nil), &blk); end
  end
end
