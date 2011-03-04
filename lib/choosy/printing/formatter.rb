require 'choosy/errors'

module Choosy::Printing
  module Formatter
    def usage_option(option)
      value = "["
      if option.short_flag
        value << option.short_flag
        if option.long_flag
          value << "|"
        end
      end
      if option.long_flag
        value << option.long_flag
      end
      if option.metaname
        if option.arity.max > 1
          value << ' '
          value << option.metaname
        else
          value << '='
          value << option.metaname
        end
      end
      value << ']'
    end

    def regular_option(option)
      value = ""
      if option.short_flag
        value << option.short_flag
        if option.long_flag
          value << ', '
        end
      else
        value << '    '
      end

      if option.long_flag
        value << option.long_flag
      end

      if option.metaname
        value << ' '
        value << option.metaname
      end
      value
    end
  end
end
