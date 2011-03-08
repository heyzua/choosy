require 'spec_helpers'
require 'choosy/super_command'

module Choosy
  describe SuperCommand do
    before :each do 
      @c = SuperCommand.new :superfoo
    end

    describe :parse! do
      it "should be able to print out the version number" do
        @c.alter do
          version "superblah"
        end

        o = capture :stdout do
          @c.parse!(['--version'])
        end

        o.should eql("superblah\n")
      end

      it "should print out the supercommand help message" do
        @c.alter do
          help
        end

        o = capture :stdout do
          @c.parse!([])
        end

        o.should match(/Usage:/)
      end

      it "should print out a subcommand help message" do
        @c.alter do
          help
          command :bar do
            boolean :count, "The count"
          end
        end

        o = capture :stdout do
          @c.parse! ['help', 'bar'] 
        end

        o.should match(/--count/)
      end
    end#parse!

    describe :execute! do
      it "should fail when no executor is present" do
        @c.alter do
          command :bar do
            boolean :count, "The count"
          end
        end

        attempting {
          @c.execute!(['bar', '--count'])
        }.should raise_error(Choosy::ConfigurationError, /No executor/)
      end

      it "should call the executors" do
        count = 0
        @c.alter do
          command :bar do
            integer :count, "The count"
            executor do |args, options|
              count = options[:count]
            end
          end
        end

        @c.execute!(['bar', '--count', '5'])
        count.should eql(5)
      end
    end#execute!
  end
end
