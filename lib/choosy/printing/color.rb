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
      :bold      => 1,
      :underline => 4,
      :blink     => 5,
      :exchange  => 7,
      :hide      => 8,
      :primary   => 10,
      :normal    => 22
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
      if disabled?
        return args[0] || "" 
      end

      if color?(method)
        raise ArgumentError.new("too many arguments to Color##{method} (max 2)") if args.length > 2
        offset = find_state(method, args[1])
        bedazzle(COLORS[method] + offset, args[0])
      elsif effect?(method)
        raise ArgumentError.new("too many arguments to Color##{method} (max 1)") if args.length > 1
        bedazzle(EFFECTS[method], args[0])
      else
        raise NoMethodError.new("undefined method '#{method}' for Color")
      end
    end

    private
    def find_state(method, state)
      case state
      when nil
        FOREGROUND
      when :foreground
        FOREGROUND
      when :background
        BACKGROUND
      else
        raise ArgumentError.new("unrecognized state for Color##{method}, :foreground or :background only")
      end
    end

    def bedazzle(number, str)
      prefix = "e#{number}[m"
      if str.nil?
        prefix
      elsif str =~ /e0\[m$/
        "#{prefix}#{str}"
      else
        "#{prefix}#{str}e0[m"
      end
    end
  end
end
