module Choosy
  class Command < BaseCommand
    attr_accessor :executor, :arguments
    attr_reader :parent

    def initialize(name, supercommand=nil)
      super(name)
      self.parent = supercommand
    end

    def parent=(value)
      @parent = value
      return if @parent.nil?
      raise Choosy::ConfigurationError.new("Parent must be a super command") unless Choosy::SuperCommand
    end
    
    def subcommand?
      !@parent.nil?
    end

    protected
    def create_builder
      Choosy::DSL::CommandBuilder.new(self)
    end

    def handle_help(hc)
      printer.print!(self)
    end

    def parse(args)
      parser = Parser.new(self)
      result = parser.parse!(args)

      verifier = Verifier.new
      verifier.verify_special!(result)
      verifier.verify!(result)
    
      result
    end

    def execute(args)
      raise Choosy::ConfigurationError.new("No executor given for: #{name}") unless executor
      result = parse!(args)
      if executor.is_a?(Proc)
        executor.call(result.args, result.options)
      else
        executor.execute!(result.args, result.options)
      end
    end
  end
end
