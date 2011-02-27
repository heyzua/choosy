require 'choosy/errors'

module Choosy::Printing
  class Color
    # Extrapolated from:
    # http://kpumuk.info/ruby-on-rails/colorizing-console-ruby-script-output/
    COLORS = {
      :black   => 0,
      :red     => 1,
      :green   => 2,
      :yellow  => 3,
      :blue    => 4,
      :magenta => 5, 
      :cyan    => 6,
      :white   => 7,
    }

    EFFECTS = {
      :reset     => 0,
      :bright    => 1,
      :underline => 4,
      :blink     => 5,
      :exchange  => 7,
      :hide      => 8
    }

    FOREGROUND = 30
    BACKGROUND = 40

    def initialize
      begin
        require 'Win32/Console/ANSI' if RUBY_PLATFORM =~ /win32/
        @disabled = false
      rescue LoadError
        # STDERR.puts "You must gem install win32console to use color on Windows"
        disable!
      end
    end

    def disabled?
      @disabled
    end

    def disable!
      @disabled = true
    end

    def color?(color)
      COLORS.has_key?(color.to_sym)
    end

    def effect?(effect)
      EFFECTS.has_key?(effect.to_sym)
    end

    def respond_to?(method)
      color?(method) || effect?(method)
    end

    # Dynamically handle colors and effects
    def method_missing(method, *args, &block)
      str, offset = unpack_args(method, args)
      return str || "" if disabled?

      if color?(method)
        bedazzle(COLORS[method] + offset, str)
      elsif effect?(method)
        bedazzle(EFFECTS[method], str)
      else
        raise NoMethodError.new("undefined method '#{method}' for Color")
      end
    end

    private
    def unpack_args(method, args)
      case args.length
      when 0
        [nil, FOREGROUND]
      when 1
        [args[0], FOREGROUND]
      when 2
        case args[1]
        when :foreground then [args[0], FOREGROUND]
        when :background then [args[0], BACKGROUND]
        else raise ArgumentError.new("unrecognized state for Color##{method}, :foreground or :background only")
        end
      else
        raise ArgumentError.new("too many arguments to Color##{method} (max 2)")
      end
    end

    def bedazzle(number, str)
      prefix = "e#{number}[m"
      if str.nil?
        prefix
      else
        "#{prefix}#{str}e0[m"
      end
    end
  end
end
