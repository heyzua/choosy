module Choosy
  Error = Class.new(RuntimeError)

  ParseError     = Class.new(Choosy::Error)
end
