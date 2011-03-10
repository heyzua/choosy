require 'spec_helpers'
require 'choosy'

module Choosy::DSL
  describe OptionBuilder do
    before :each do
      @builder = OptionBuilder.new(:stub)
      @option = @builder.entity
    end
    
    describe :name do
      it "should set the name" do
        @option.name.should eql(:stub)
      end
    end

    describe :short do
      it "should set the option" do
        @builder.short '-s'
        @option.short_flag.should eql('-s')
      end

      describe "and the arity" do
        it "should not be set without a metaname" do
          @builder.short '-s'
          @option.short_flag.should eql('-s')
          @option.arity.should be(nil)
        end

        it "should be set on STD+ metaname" do
          @builder.short '-s', 'STD+'
          @option.arity.should eql(1..1000)
        end

        it "should set single arity on STD metaname" do
          @builder.short '-s', 'STD'
          @option.arity.should eql(1..1)
        end

        it "should not set the arity if :count has already been called" do
          @builder.count 3
          @builder.short '-s', 'STD'
          @option.arity.should eql(3..3)
        end
      end

      describe "and the flag metaname" do
        it "on STD metanames" do
          @builder.short '-s', 'STD'
          @option.metaname.should eql('STD')
        end

        it "on STD+ metanames" do
          @builder.short '-s', 'STD+'
          @option.metaname.should eql('STD+')
        end
      end
    end#short

    describe :long do
      it "should set the flag correctly" do
        @builder.long '--short'
        @option.long_flag.should eql('--short')
      end

      describe "while setting arity" do
        it "should not set arity on empty" do
          @builder.long '--short'
          @option.arity.should be(nil)
        end

        it "should set the arity on STD to 1" do
          @builder.long '--short', 'STD'
          @option.arity.should eql(1..1)
        end

        it "should set the arity on STD+ to 1+" do
          @builder.long '--short', 'STD+'
          @option.arity.should eql(1..1000)
        end
      end#arity

      describe "and the flag metaname" do
        it "on STD metanames" do
          @builder.long '-s', 'STD'
          @option.metaname.should eql('STD')
        end

        it "on STD+ metanames" do
          @builder.long '-s', 'STD+'
          @option.metaname.should eql('STD+')
        end
      end
    end#long

    describe :flags do
      it "should be able to set the short flag" do
        @builder.flags '-s'
        @option.short_flag.should eql('-s')
      end

      it "should the long flag unset when just the short flag is given" do
        @builder.flags '-s'
        @option.long_flag.should be(nil)
      end

      it "should leave the param nil when just the short flag is given" do
        @builder.flags '-s'
        @option.metaname.should be(nil)
      end

      it "should be able to set the short when the long flag is given" do
        @builder.flags '-s', '--short'
        @option.short_flag.should eql('-s')
      end

      it "should be able to set the long flag when given" do
        @builder.flags '-s', '--short'
        @option.long_flag.should eql('--short')
      end

      it "should leave the metaname empty when not given" do
        @builder.flags '-s', '--short'
        @option.metaname.should be(nil)
      end

      it "should set the metaname if given" do
        @builder.flags '-s', '--short', 'SHORT'
        @option.metaname.should eql('SHORT')
      end
    end#flags

    describe :desc do
      it "should set the option correctly" do
        @builder.desc "This is an option"
        @option.description.should =~ /^This/
      end
    end#desc

    describe :default do
      it "should set the option" do
        @builder.default :clear
        @option.default_value.should eql(:clear)
      end
    end#default

    describe :die do
      it "should format the error message with both flags" do
        @builder.short '-k'
        @builder.long '--keep', 'KEEP'
        attempting {
          @builder.die "Didn't keep anything"
        }.should raise_error(Choosy::ValidationError, /-k\/--keep KEEP: Didn't keep anything/)
      end

      it "should set the format of the error with the short flag" do
        @builder.short '-k'
        attempting {
          @builder.die "Didn't keep anything"
        }.should raise_error(Choosy::ValidationError, /-k: Didn't keep anything/)
      end

      it "should set the format of the long flag alone" do
        @builder.long '--keep'
        attempting {
          @builder.die "Didn't keep anything"
        }.should raise_error(Choosy::ValidationError, /--keep: Didn't keep anything/)
      end
    end#die

    describe :depends_on do
      it "should be able to process multiple arguments" do
        @builder.depends_on :a, :b
        @option.dependent_options.should eql([:a, :b])
      end

      it "should be able to process Array arguments" do
        @builder.depends_on [:a, :b]
        @option.dependent_options.should eql([:a, :b])
      end
    end#depends_on

    describe :only do
      it "should set the allowable_values for an option" do
        @builder.only :this, :that, :other
        @option.allowable_values.should eql([:this, :that, :other])
      end
    end#only

    describe :negate do
      it "should set the default negation to 'no'" do
        @builder.negate
        @option.negated?.should be_true
        @option.negation.should eql('no')
      end

      it "should set the the negation to a specific value" do
        @builder.negate 'non'
        @option.negated?.should be_true
        @option.negation.should eql('non')
      end
    end#negate

    describe :from_hash do
      it "should fail on unrecognized methods" do
        attempting {
          @builder.from_hash :not_a_method => "ha!"
        }.should raise_error(Choosy::ConfigurationError, /Not a recognized option/)
      end
      
      it "should handle the short option" do
        @builder.from_hash :short => ['-s', 'SHORT+']
        @option.short_flag.should eql('-s')
      end

      it "should handle the desc option" do
        @builder.from_hash :desc => "description"
        @option.description.should eql("description")
      end

      it "should be able to handle multiple options" do
        @builder.from_hash({:short => '-s', :desc => 'description'})
        @option.short_flag.should eql('-s')
        @option.description.should eql('description')
      end

      it "should be able to handle complicated arguments like :count" do
        @builder.from_hash({:count => {:at_least => 3, :at_most => 5}})
        @option.arity.should eql(3..5)
      end

      it "should fail when the argument isn't a hash" do
        attempting {
          @builder.from_hash("")
        }.should raise_error(Choosy::ConfigurationError, /Only hash arguments allowed/)
      end
    end#from_hash
  end
end
