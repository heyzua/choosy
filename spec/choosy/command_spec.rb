module Choosy
  describe Command do
    before :each do
      @c = Command.new :foo do
        arguments
      end
    end

    describe :parse! do
      it "should print out the version number" do
        @c.alter do
          version "blah"
        end

        o = capture :stdout do
          attempting {
            @c.parse!(['--version'])
          }.should raise_error(SystemExit)
        end

        o.should eql("blah\n")
      end

      it "should print out the help info" do
        @c.alter do
          summary "Summary"
          help
        end

        o = capture :stdout do
          attempting {
            @c.parse!(['--help'])
          }.should raise_error(SystemExit)
        end

        o.should match(/--help/)
      end

      it "should make sure that help gets check before other required options" do
        @c.alter do
          help
          string :str, "String", :required => true
        end

        o = capture do
          attempting {
            @c.parse! ['--help']
          }.should raise_error(SystemExit)
        end

        o.should match(/--help/)
      end
    end

    describe :execute! do
      it "should fail when no executor is given" do
        attempting {
         @c.execute!(['a', 'b'])
        }.should raise_error(Choosy::ConfigurationError, /No executor/)
      end

      it "should call an proc" do
        p = nil
        @c.executor = Proc.new {|args, options| p = args}
        @c.execute!(['a', 'b'])
        p.should eql(['a', 'b'])
      end

      class FakeExecutor
        attr_reader :called
        def execute!(args, options)
          @called = args
        end
      end

      it "should call an executor if given" do
        exec = FakeExecutor.new
        @c.executor = exec
        @c.execute!(['a'])
        exec.called.should eql(['a'])
      end
    end
  end
end
