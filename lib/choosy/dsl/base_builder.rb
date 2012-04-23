module Choosy::DSL
  # Must have entity attribute
  module BaseBuilder
    # Adapted from: http://www.dcmanges.com/blog/ruby-dsls-instance-eval-with-delegation
    def evaluate!(&block)
      if block_given?
        @self_before_instance_eval = eval "self", block.binding
        instance_eval(&block)
      end
      @self_before_instance_eval = nil

      entity.finalize!
      entity
    end
    
    def method_missing(method, *args, &block)
      if @self_before_instance_eval
        @self_before_instance_eval.send(method, *args, &block)
      else
        raise NoMethodError.new("undefined method '#{method}' for #{self.class.name}")
      end
    end
  end
end
