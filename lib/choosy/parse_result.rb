require 'choosy/verifier'

module Choosy
  class BaseParseResult
    attr_reader :command, :options, :unparsed

    def initialize(command, subresult)
      @command = command
      @options = {}
      @unparsed = []
      @subresult = subresult
    end 

    def [](opt)
      @options[opt]
    end

    def []=(opt, val)
      @options[opt] = val
    end

    def subresult?
      @subresult
    end
  end

  class ParseResult < BaseParseResult
    attr_reader :args

    def initialize(command, subresult)
      super(command, subresult)
      @args = []
    end
  end

  class SuperParseResult < BaseParseResult
    attr_reader :subresults

    def initialize(command)
      super(command, false)
      @subresults = []
    end

  end
end
