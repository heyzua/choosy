require 'choosy/errors'
require 'time'

module Choosy
  class Converter
    CONVERSIONS = {
      Integer => [:integer, :int],
      Float => [:float],
      Symbol => [:symbol],
      File => [:file],
      Date => [:date],
      Time => [:time],
      DateTime => [:datetime],
      String => [:string]
    }
    BOOLEANS = [:boolean, :bool]
    
    def self.for(ty)
      if ty.is_a?(Class)
        vals = CONVERSIONS[ty]
        return vals[0] if !vals.nil?
      elsif BOOLEANS.include?(ty)
        return :boolean
      elsif ty.is_a?(Symbol)
        CONVERSIONS.each_value do |v|
          return v[0] if v.include?(ty)
        end
      end

      nil
    end
  end
end
