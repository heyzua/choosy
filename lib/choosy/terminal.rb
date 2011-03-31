require 'choosy/errors'
require 'choosy/printing/color'

module Choosy
  module Terminal
    DEFAULT_LINE_COUNT = 25
    DEFAULT_COLUMN_COUNT = 80

    attr_writer :lines, :columns

    def lines
      @lines ||= find_terminal_size('LINES', 'lines', 0) || DEFAULT_LINE_COUNT
    end

    def columns
      @columns ||= find_terminal_size('COLUMNS', 'cols', 1) || DEFAULT_COLUMN_COUNT
    end

    def color
      @color ||= Choosy::Printing::Color.new
    end

    def pager?
      !pager.empty?
    end

    def pager
      @pager ||= nil
      return @pager if @pager

      @pager ||= ENV['PAGER'] || 
                  ENV['MANPAGER'] ||
                  if command_exists?('less')
                    'less -R'
                  elsif command_exists?('more')
                    'more'
                  else
                    ''
                  end
      if @pager !~ /less -R/
        color.disable! 
      end
      @pager
    end

    def page(contents, pipe_command=nil)
      if pager?
        if pipe_command
          pipe_out("#{pipe_command} | #{pager}", contents)
        else
          pipe_out(pager, contents)
        end
      else
        pipe_out(pipe_command, contents)
      end
    end

    def pipe_out(command, contents = nil, &block)
      puts contents if command.nil? && contents

      IO.popen(command, 'w') do |f|
        f.puts contents if contents
        if block_given?
          yield f
        end
      end
    end
    
    def pipe_in(command = nil, &block)
      raise ArgumentError.new("Requires a block") unless block_given?

      if command
        IO.popen(command, 'r') do |f|
          f.each_line do |line|
            yield line
          end
        end
        $?
      elsif stdin?
        STDIN.each_line do |line|
          yield line
        end
        0
      else
        1
      end
    end

    # directly from hirb
    def command_exists?(command)
      ENV['PATH'].split(File::PATH_SEPARATOR).any? {|d| File.exists? File.join(d, command) }
    end

    def stdin?
      begin
        require 'fcntl'
        STDIN.fcntl(Fcntl::F_GETFL, 0) == 0 && !stdin.tty?
      rescue
        $stdin.stat.size != 0
      end
    end

    def unformatted(line='')
      line = line.gsub(/\e\[\d+m/, '')
      line.gsub!(/\\f[IPB]/, '')
      line
    end

    def die(message)
      raise Choosy::ValidationError.new(message)
    end

    private
    # https://github.com/cldwalker/hirb
    # modified from hirb
    def find_terminal_size(env_name, tput_name, stty_index)
      begin 
        if ENV[env_name] =~ /^\d$/
          ENV[env_name].to_i
        elsif (RUBY_PLATFORM =~ /java/ || (!STDIN.tty? && ENV['TERM'])) && command_exists?('tput')
          `tput #{tput_name}`.to_i
        elsif STDIN.tty? && command_exists?('stty')
          `stty size`.scan(/\d+/).map { |s| s.to_i }[stty_index]
        else
          nil
        end
      rescue
        nil
      end
    end
  end
end
