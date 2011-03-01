module Choosy
  Error = Class.new(RuntimeError)

  ConfigurationError = Class.new(Choosy::Error)
  ValidationError    = Class.new(Choosy::Error)
  HelpCalled         = Class.new(Choosy::Error)
  VersionCalled      = Class.new(Choosy::Error)
  ConversionError    = Class.new(Choosy::Error)
  ParseError         = Class.new(Choosy::Error)
  CommandLineError   = Class.new(Choosy::Error)
end
