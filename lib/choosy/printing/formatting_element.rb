require 'choosy/errors'

module Choosy::Printing
  class FormattingElement
    attr_reader :value, :attrs, :kind

    def initialize(kind, value, attrs)
      @value = value
      @kind = kind
      @attrs = attrs
    end

    def header?
      @kind == :header
    end
  end
end
