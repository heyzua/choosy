module Choosy
  Error = Class.new(RuntimeError)

  ConfigurationError = Class.new(Choosy::Error)
  ValidationError    = Class.new(Choosy::Error)
  ConversionError    = Class.new(Choosy::Error)
  ParseError         = Class.new(Choosy::Error)
  SuperParseError    = Class.new(Choosy::Error)
  VersionError       = Class.new(Choosy::Error)
  ClientExecutionError = Class.new(Choosy::Error)

  class HelpCalled < Choosy::Error
    def initialize(m); @m = m; end
    def message; @m; end
  end

  class VersionCalled < Choosy::Error
    def initialize(m); @m = m; end
    def message; @m; end
  end
end
