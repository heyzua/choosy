require 'choosy/verifier'

module Choosy
  class BaseParseResult
    attr_reader :command, :options, :unparsed

    def initialize(command)
      @command = command
      @options = {}
      @unparsed = []
    end 

    def [](opt)
      @options[opt]
    end

    def []=(opt, val)
      @options[opt] = val
    end
  end

  class ParseResult < BaseParseResult
    attr_reader :args

    def initialize(command)
      super(command)
      @args = []
    end
  end

  class SuperParseResult < BaseParseResult
    attr_reader :subresults

    def initialize(command)
      super(command)
      @subresults = []
    end
  end
end
