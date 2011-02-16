require 'choosy/errors'
require 'time'

module Choosy
  class Converter
    CONVERSIONS = {
      Integer => :integer,
      Float => :float,
      Symbol => :symbol,
      File => :file,
      Date => :date,
      Time => :time,
      DateTime => :datetime
    }
    
    def self.for_type(ty)
      CONVERSIONS[ty]
    end

    
  end
end
