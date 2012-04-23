module Choosy
  class ParserBuilder
    attr_reader :command, :lazy

    def initialize
      @terminals = nil
      @lazy = false
      @command = Choosy::Command.new(:parser)
    end

    def lazy!
      @lazy = true
      self
    end

    def parse!(*args)
      parser = build
      parser.parse!(args)
    end

    def terminals(*terms)
      @terminals = terms
      self
    end

    def boolean(sym, default=nil, negated=nil)
      default ||= false
      negated ||= false
      @command.alter do
        boolean(sym, sym.to_s, :default => default) do
          if negated
            negate
          end
        end
      end
      self
    end

    def single(sym)
      @command.alter do
        single(sym, sym.to_s)
      end
      self
    end

    def multiple(sym, min=nil, max=nil)
      min ||= 1
      max ||= 1000
      @command.alter do
        multiple(sym, sym.to_s) do
          count :at_least => min, :at_most => max
        end
      end
      self
    end

    def build
      Parser.new(@command, @lazy, @terminals)
    end
  end

  describe Parser do
    before :each do
      @pb = ParserBuilder.new
    end

    describe "with no options" do
      it "should handle everyting after the '--'" do
        @pb.parse!('--', '-a', 'not an option').args.should have(2).items
      end

      it "should be able to parse a list of unremarvable objects" do
        @pb.parse!('a', 'b', 'c').args.should have(3).items
      end

      it "should stop when it encounters a terminal" do
        @pb.terminals('a', 'b')
        res = @pb.parse!('c', 'n', 'b', 'q')
        res.args.should eql(['c', 'n'])
        res.unparsed.should eql(['b', 'q'])
      end

      it "should capture even if the first item is a terminal" do
        res = @pb.terminals('a').parse!('a', 'b')
        res.unparsed.should eql(['a', 'b'])
      end
    end

    describe "when being built" do
      it "should fail when duplicate short options are given" do
        @pb.boolean :opt
        @pb.boolean :opt2
        attempting {
          @pb.build
        }.should raise_error(Choosy::ConfigurationError, /Duplicate option: '-o'/)
      end

      it "should fail when duplicate long options are given" do
        @pb.boolean :opt
        @pb.boolean :Opt
        attempting {
          @pb.build
        }.should raise_error(Choosy::ConfigurationError, /Duplicate option: '--opt'/)
      end
    end

    describe "while unsuccessfully parsing arguments" do
      it "should fail with an unassociated '-'" do
        attempting {
          @pb.parse!('a', '-')
        }.should raise_error(Choosy::ParseError, /'-'/)
      end

      it "should fail on unrecognized option" do
        attempting {
          @pb.parse!('a', '-l')
        }.should raise_error(Choosy::ParseError, "Unrecognized option: '-l'")
      end

      it "should fail when a boolean argument attaches an argument" do
        attempting {
          @pb.boolean(:o).parse!('-o=blah')
        }.should raise_error(Choosy::ParseError, "Argument given to boolean flag: '-o=blah'")
      end

      it "should fail when a required argument is missing" do
        attempting {
          @pb.single(:option).parse!('-o')
        }.should raise_error(Choosy::ParseError, "Argument missing for option: '-o'")
      end

      describe "of multiple arity" do
        it "should fail when not enough arguments are provided after the '='" do
          attempting {
            @pb.multiple(:option, 2).parse!('-o=Opt')
          }.should raise_error(Choosy::ParseError, "The '-o' flag requires at least 2 arguments")
        end

        it "should fail when not enough arguments are provided" do
          attempting {
            puts @pb.multiple(:option, 3).parse!('-o', 'Opt', 'OO').options
          }.should raise_error(Choosy::ParseError, "The '-o' flag requires at least 3 arguments")
        end
      end
    end

    describe "while successfully parsing options" do
      it "should handle a single short boolean argument" do
        res = @pb.boolean(:o).parse!('-o')
        res.args.should be_empty
        res.options.should eql({:o => true})
      end

      it "should handle negated boolean arguments" do
        @pb.boolean(:o, false, true)
        @pb.build.flags['--no-o'].should_not be_nil
      end

      it "should handle a negated boolean argument" do
        res = @pb.boolean(:o, false, true).parse!('--no-o')
        res.options.should eql({:o => false})
      end

      it "should handle a negated boolean argument whose default is true" do
        res = @pb.boolean(:o, true, true).parse!('--no-o')
        res.options.should eql({:o => true})
      end

      it "should handle a boolean flag whose default is true" do
        res = @pb.boolean(:opt, true).parse!('-o')
        res.options.should eql({:opt => false})
      end

      it "should handle a flag with an arity of 1" do
        res = @pb.single(:option).parse!('-o', 'Opt')
        res.args.should be_empty
        res.options.should eql({:option => 'Opt'})
      end

      it "should handle a flag of arity 1 with an '=' sign" do
        res = @pb.single(:option).parse!('-o=Opt')
        res.args.should be_empty
        res.options.should eql({:option => 'Opt'})
      end

      describe "of multiple arity" do
        it "should parse a single argument" do
          res = @pb.multiple(:option).parse!('-o', 'Opt')
          res.args.should be_empty
          res.options.should eql({:option => ['Opt']})
        end

        it "should leave args at the end if limited in size" do
          res = @pb.multiple(:option, 1, 2).parse!('-o', '1', '2', '3')
          res.args.should eql(['3'])
          res.options.should eql({:option => ['1', '2']})
        end

        it "should handle the '-' part to end argument parsing to options" do
          res = @pb.multiple(:option).parse!('-o', '1', '2', '-', '3')
          res.args.should eql(['3'])
          res.options.should eql({:option => ['1', '2']})
        end
      end

      describe "in combination" do
        it "should handle multiple boolean flags" do
          @pb.boolean(:abs)
          @pb.boolean(:not)
          res = @pb.parse!('-a', '-n', 'q')
          res.args.should eql(['q'])
          res.options.should eql({:abs => true, :not => true})
        end

        it "should be able to hantld multi-arg options and booleans" do
          @pb.boolean(:abs)
          @pb.multiple(:mult)
          res = @pb.parse!('a', '-m', 'b', 'c', '-a', 'c')
          res.args.should eql(['a', 'c'])
          res.options.should eql({:abs => true, :mult => ['b', 'c']})
        end

        it "should be able to handle multiple single arg options" do
          @pb.single(:sub)
          @pb.single(:add)
          res = @pb.parse!('-s', '1', '3', '-a', '2', '4')
          res.args.should eql(['3', '4'])
          res.options.should eql({:sub => '1', :add => '2'})
        end
      end
    end

    describe "while being lazy" do
      it "should keep extra arguments as unparsed" do
        res = @pb.lazy!.parse!('a', 'b')
        res.unparsed.should eql(['a', 'b'])
      end

      it "should simply retain the '-' character" do
        res = @pb.lazy!.parse!('a', '-', 'b')
        res.unparsed.should eql(['a', '-', 'b'])
      end

      it "should feed args after '--'" do
        res = @pb.lazy!.parse!('a', '--', 'z')
        res.unparsed.should eql(['a', '--', 'z'])
      end

      it "should skip options it doesn't capture" do
        res = @pb.lazy!.parse!('-a', 'b')
        res.unparsed.should eql(['-a', 'b'])
        res.options.should eql({})
      end

      it "should skip irrelevant boolean args" do
        res = @pb.lazy!.boolean(:opt).parse!('a', '-b', '--opt', 'c')
        res.unparsed.should eql(['a', '-b', 'c'])
      end

      it "should capture relevant boolean args" do
        res = @pb.lazy!.boolean(:opt).parse!('a', '-b', '--opt', 'c')
        res.options.should eql({:opt => true})
      end

      it "should capture relevant 1 arity args" do
        res = @pb.lazy!.single(:opt).parse!('-a', 'n', '-o', 'i', 'q')
        res.options.should eql({:opt => 'i'})
      end

      it "should skip uncaptured 1 arity args" do
        res = @pb.lazy!.single(:opt).parse!('-a', 'n', '-o', 'i', 'q')
        res.unparsed.should eql(['-a', 'n', 'q'])
      end

      it "should capture multipe argument items" do
        res = @pb.lazy!.multiple(:opt).parse!('-a', '-o', 'r', 's', 't', '-', 'q')
        res.options.should eql({:opt => ['r', 's', 't']})
      end

      it "should skip anything stopped by the '-' in a multi-arg parse" do
        res = @pb.lazy!.multiple(:opt).parse!('-a', '-o', 'r', 's', 't', '-', 'q')
        res.unparsed.should eql(['-a', 'q'])
      end

      it "should include the terminals in the unparsed part" do
        res = @pb.lazy!.boolean(:a).terminals('b', 'c').parse!('q', '-a', 'b', 'c')
        res.unparsed.should eql(['q', 'b', 'c'])
      end
    end#lazy
  end
end

