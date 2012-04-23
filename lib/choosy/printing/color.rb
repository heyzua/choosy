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

    KINDS = {
      :foreground => 30,
      :background => 40
    }

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

    def color?(col)
      COLORS.has_key?(col.to_sym)
    end

    def effect?(effect)
      EFFECTS.has_key?(effect.to_sym)
    end

    def multiple(str, styles)
      return str if styles.nil? || styles.empty? || disabled?

      originally_nil = str.nil?
      styles.each do |style|
        if color?(style)
          str = bedazzle(COLORS[style] + KINDS[:foreground], str, originally_nil)
        elsif effect?(style)
          str = bedazzle(EFFECTS[style], str, originally_nil)
        end
      end
      str
    end

    COLORS.each do |color, number|
      define_method color do |*args|
        raise ArgumentError, "Too many arguments, (max 2)" if args.length > 2

        return args[0] || "" if disabled?
        kind = args[1]
        if kind && !KINDS.has_key?(kind)
          raise ArgumentError, "Unrecognized format, only :foreground or :background supported"
        end

        bedazzle(number + KINDS[(kind || :foreground)], args[0])
      end
    end

    EFFECTS.each do |color, number|
      define_method color do |*args|
        raise ArgumentError, "Too many arguments, (max 1)" if args.length > 1

        return args[0] || "" if disabled?
        bedazzle(number, args[0])
      end
    end

    private
    def bedazzle(number, str, keep_open=nil)
      prefix = "\e[#{number}m"
      if str.nil?
        prefix
      elsif str =~ /\e\[0m$/
        "#{prefix}#{str}"
      elsif keep_open
        "#{prefix}#{str}"
      else
        "#{prefix}#{str}\e[0m"
      end
    end
  end
end
