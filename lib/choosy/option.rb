require 'choosy/argument'

module Choosy
  class Option < Argument
    attr_accessor :name, :description
    attr_accessor :short_flag, :long_flag
    attr_accessor :default_value
    attr_accessor :dependent_options
    attr_accessor :negation

    def initialize(name)
      super()
      @name = name
    end

    def negated?
      !negation.nil?
    end

    def negated
      @negated ||= long_flag.gsub(/^--/, "--#{negation}-")
    end
  end
end
