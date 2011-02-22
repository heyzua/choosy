require 'choosy/errors'

module Choosy::DSL
  class CommandBuilder
    
    
    def initialize(command)
      @command = command
    end

    def executor(exec=nil, &block)
      if exec.nil? 
        if block_given?
          @command.executor = block
        else
          raise Choosy::ConfigurationError.new("The executor was nil")
        end
      else
        if !exec.respond_to?(:execute!)
          raise Choosy::ConfigurationError.new("Execution class doesn't implement 'execute!'")
        end
        @command.executor = exec
      end
    end

    def summary(msg)
      @command.summary = msg
    end
    
    def desc(msg)
      @command.description = msg
    end
  end
end
