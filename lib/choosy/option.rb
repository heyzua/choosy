module Choosy
  class Option
    attr_accessor :symbol, :description
    attr_accessor :short_flag, :long_flag, :flag_parameter
    attr_accessor :cast_to,  :default_value
    attr_accessor :validation_step
    attr_accessor :arity
    attr_accessor :dependent_options

    
        
    def required=(req)
      @required = req
    end
    def required?
      @required == true
    end
  end
end
