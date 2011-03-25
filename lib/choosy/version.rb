require 'yaml'
require 'time'
require 'choosy/errors'

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

    private
    VERSION = 'version'
    TINY = 'tiny'
    MINOR = 'minor'
    MAJOR = 'major'
    VERSIONS = [TINY, MINOR, MAJOR]
    DATE = 'date'
  end
end
