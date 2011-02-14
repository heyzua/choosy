module Choosy
  Error = Class.new(RuntimeError)

  ConfigurationError = Class.new(Choosy::Error)
  ValidationError    = Class.new(Choosy::Error)
  ParseError         = Class.new(Choosy::Error)
end
