module Choosy
  class Option
    attr_accessor :name, :description
    attr_accessor :short_flag, :long_flag, :metaname
    attr_accessor :cast_to,  :default_value
    attr_accessor :validation_step
    attr_accessor :arity
    attr_accessor :dependent_options

    def initialize(name)
      @name = name
      @required = false
    end
    
    def required=(req)
      @required = req
    end
    def required?
      @required == true
    end
  end
end
