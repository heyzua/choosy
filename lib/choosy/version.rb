module Choosy
  class Version
    attr_accessor :date_format, :version_file

    def initialize(version_file, date_format='%d/%m/%Y')
      if !File.file?(version_file)
        raise Choosy::ConfigurationError.new("No version file given: #{version_file}")
      end

      @version_file = version_file
      @date_format = date_format
      reload!
    end

    def tiny
      @contents[VERSION][TINY]
    end

    def minor
      @contents[VERSION][MINOR]
    end

    def major
      @contents[VERSION][MAJOR]
    end
    
    def date
      @contents[DATE]
    end

    def reload!
      @contents = YAML.load_file(@version_file)
    end

    def version!(kind)
      kind = kind.to_s
      unless VERSIONS.include?(kind)
        raise Choosy::VersionError.new("Wrong versioning schema: #{kind}") 
      end

      VERSIONS.each do |vers|
        if vers == kind
          @contents[VERSION][kind] += 1
          break
        else
          @contents[VERSION][vers] = 0
        end
      end
      @contents[DATE] = Time.now.strftime(@date_format)
      File.open(@version_file, 'w') do |out|
        YAML.dump(@contents, out)
      end
    end

    def to_s
      "#{major}.#{minor}.#{tiny}"
    end

    def ==(other)
      major == other.major && minor == other.minor && tiny == other.tiny
    end

    def eql?(other)
      self == other
    end

    def <=>(other)
      if major >= other.major || minor >= other.minor || tiny >= other.tiny
        1
      elsif major <= other.major || minor <= other.minor || tiny <= other.tiny
        -1
      else
        0
      end
    end

    def self.method_missing(method, *args, &block)
      if method.to_s =~ /^load_from_(.*)$/
        parts = $1.split(/_/)
        parts.map! do |part|
          case part
          when 'here'   then '.'
          when 'parent' then '..'
          else part
          end
        end

        basedir = if args.length == 0
                    # Find the path to the calling file
                    # How awesome is this !?
                    File.dirname(caller(1)[0].split(/:/)[0])
                  else
                    args.join(File::Separator)
                  end

        path = File.join(basedir, *parts)
        load_from(path)
      else
        super
      end
    end

    private
    VERSION = 'version'
    TINY = 'tiny'
    MINOR = 'minor'
    MAJOR = 'major'
    VERSIONS = [TINY, MINOR, MAJOR]
    DATE = 'date'

    def self.load_from(basepath)
      [File.join(basepath, 'VERSION.yml'), File.join(basepath, 'version.yml')].each do |path|
        if File.exist?(path)
          return Version.new(path)
        end
      end

      raise Choosy::ConfigurationError.new("No version file given from: #{basepath}")
    end
  end
end
