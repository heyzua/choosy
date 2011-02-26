require 'choosy/errors'
require 'time'
require 'date'

module Choosy
  class Converter
    CONVERSIONS = {
      :integer => nil,
      :int     => :integer,
      :float   => nil,
      :symbol  => nil,
      :file    => nil,
      :date    => nil,
      :time    => nil,
      :datetime => nil,
      :string  => nil,
      :boolean => nil,
      :bool    => :boolean
    }

    def self.for(ty)
      if ty.is_a?(Symbol) && CONVERSIONS.has_key?(ty)
        val = CONVERSIONS[ty]
        if val
          return val 
        else
          return ty
        end
      elsif ty.respond_to?(:convert)
        return ty
      end

      nil
    end

    def self.convert(ty, value)
      if CONVERSIONS.has_key?(ty)
        send(ty, value)
      else
        ty.convert(value)
      end
    end

    def self.integer(value)
      begin
        return Integer(value)
      rescue ArgumentError
        raise Choosy::ConversionError.new("Unable to convert '#{value}' into an integer")
      end
    end

    def self.float(value)
      begin
        return Float(value)
      rescue ArgumentError
        raise Choosy::ConversionError.new("Unable to convert '#{value}' into a float")
      end
    end

    def self.symbol(value)
      value.to_sym
    end

    def self.file(value)
      File.new(value)
    end

    def self.date(value)
      begin
        return Date.parse(value)
      rescue ArgumentError
        raise Choosy::ConversionError.new("Unable to convert '#{value}' into a date")
      end
    end

    def self.time(value)
      begin
        return Time.parse(value)
      rescue ArgumentError
        raise Choosy::ConversionError.new("Unable to convert '#{value}' into a time")
      end
    end

    def self.datetime(value)
      begin
        return DateTime.parse(value)
      rescue ArgumentError
        raise Choosy::ConversionError.new("Unable to convert '#{value}' into datetime")
      end
    end
  end
end
