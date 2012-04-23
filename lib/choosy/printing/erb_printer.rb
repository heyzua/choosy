require 'erb'

module Choosy::Printing
  class ERBPrinter < HelpPrinter
    attr_reader :command, :template

    def initialize(options)
      super(options)
      if options[:template].nil?
        raise Choosy::ConfigurationError.new("no template file given to ERBPrinter")
      elsif !File.file?(options[:template])
        raise Choosy::ConfigurationError.new("the template file doesn't exist: #{options[:template]}")
      end
      @template = options[:template]
    end

    def print!(command)
      @command = command
      contents = nil
      File.open(template, 'r') {|f| contents = f.read }
      erb = ERB.new contents

      erb.result(self)
    end

    def erb_binding
      binding
    end
  end
end
