require 'choosy/errors'
require 'time'
require 'date'
require 'yaml'

module Choosy
  class Converter
    CONVERSIONS = {
      :integer => nil,
      :int     => :integer,
      :float   => nil,
      :symbol  => nil,
      :file    => nil,  # Succeeds only if a file is present
      :yaml    => nil,  # Loads a YAML file, if present
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
      if ty.nil?
        raise ArgumentError.new("Can't convert nil to a type.")
      end

      if CONVERSIONS.has_key?(ty)
        send(ty, value)
      else
        ty.convert(value)
      end
    end

    def self.boolean(value)
      value # already set
    end

    def self.string(value)
      value # already set
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
      if File.exist?(value)
        File.new(value)
      else
        raise Choosy::ValidationError.new("Unable to locate file: '#{value}'")
      end
    end

    def self.yaml(value)
      fd = file(value)
      begin
        return YAML::load_file(fd.path)
      rescue Error
        raise Choosy::ConversionError.new("Unable to load YAML from file: '#{value}'")
      end
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
