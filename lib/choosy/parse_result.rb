require 'choosy/verifier'

module Choosy
  class BaseParseResult
    attr_reader :command, :options, :unparsed

    def initialize(command)
      @command = command
      @options = {}
      @unparsed = []
      @verified = false
    end 

    def [](opt)
      @options[opt]
    end

    def []=(opt, val)
      @options[opt] = val
    end

    def verified?
      @verified
    end

    def verify!
      basic_verification
    end

    protected
    def basic_verification(&block)
      verifier = Verifier.new
      verifier.verify_options!(self)
      yield verifier if block_given?
      @verified = true
      self
    end
  end

  class ParseResult < BaseParseResult
    attr_reader :args

    def initialize(command)
      super(command)
      @args = []
    end

    def verify!
      return self if verified?
      basic_verification do |verifier|
        verifier.verify_arguments!(self)
      end
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
