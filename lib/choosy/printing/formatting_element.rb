require 'choosy/errors'

module Choosy::Printing
  class FormattingElement
    attr_reader :value, :styles, :kind

    def initialize(kind, value, styles)
      @value = value
      @kind = kind
      @styles = styles
    end

    def header?
      @kind == :header
    end
  end
end
