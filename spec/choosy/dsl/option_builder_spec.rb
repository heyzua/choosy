require 'spec_helpers'
require 'choosy'

module Choosy::DSL
  describe OptionBuilder do
    before :each do
      @builder = OptionBuilder.new(:stub)
      @option = @builder.option
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

    describe :required do
      it "should set the option" do
        @builder.required
        @option.required?.should be(true)
      end

      it "should set the option on non-nil/non-true" do
        @builder.required 1
        @option.required?.should be(false)
      end

      it "should set the option on false" do
        @builder.required false
        @option.required?.should be(false)
      end
    end#required

    describe :metaname do
      it "should be able to set the name of the metaname" do
        @builder.metaname 'PARAM'
        @option.metaname.should eql('PARAM')
      end

      it "should set the arity on STD+ to 1+" do
        @builder.metaname 'STD+'
        @option.arity.should eql(1..1000)
      end

      it "should set the arity on STD to 1" do
        @builder.metaname 'STD'
        @option.arity.should eql(1..1)
      end
    end#metaname

    describe :count do
      describe "when welformed" do
        it "should set :at_least the right arity" do
          @builder.count :at_least => 32
          @option.arity.should eql(32..1000)
        end

        it "should set :at_most the right arity" do
          @builder.count :at_most => 31
          @option.arity.should eql(1..31)
        end

        it "should set :once to the right arity" do
          @builder.count :once
          @option.arity.should eql(1..1)
        end

        it "should set :zero to the right arity" do
          @builder.count :zero
          @option.arity.should eql(0..0)
        end

        it "should set :none to the right arity" do
          @builder.count :none
          @option.arity.should eql(0..0)
        end

        it "should set a number exactly" do
          @builder.count 3
          @option.arity.should eql(3..3)
        end

        it "should allow for a range" do
          @builder.count 1..2
          @option.arity.should eql(1..2)
        end
      end

      describe "when malformed" do
        it "should fail when the :exactly isn't a number" do
          attempting {
            @builder.count :exactly => 'p'
          }.should raise_error(Choosy::ConfigurationError, /number/)
        end

        it "should fail when the :at_most isn't a number" do
          attempting {
            @builder.count :at_most => 'p'
          }.should raise_error(Choosy::ConfigurationError, /number/)
        end

        it "should fail when the :at_least isn't a number" do
          attempting {
            @builder.count :at_least => 'p'
          }.should raise_error(Choosy::ConfigurationError, /number/)
        end

        it "should fail when the :count isn't a number" do
          attempting {
            @builder.count 'p'
          }.should raise_error(Choosy::ConfigurationError, /number/)
        end

        it "should fail when the :at_least is greater than :at_most" do
          attempting {
            @builder.count :at_least => 3, :at_most => 2
          }.should raise_error(Choosy::ConfigurationError, /lower bound/)
        end
      end
    end#count

    describe :cast do
      it "should allow symbol casts" do
        @builder.cast :int
        @option.cast_to.should eql(:integer)
      end
  
      class CustomConverter
        def convert(value)
        end
      end

      it "should allow for custom conversions" do
        conv = CustomConverter.new
        @builder.cast conv
        @option.cast_to.should be(conv)
      end

      it "should fail if it doesn't know about a Type" do
        attempting {
          @builder.cast Choosy::Error
        }.should raise_error(Choosy::ConfigurationError, /Unknown conversion/)
      end

      it "should fail if it doesn't know about a symbol" do
        attempting {
          @builder.cast :unknown_type
        }.should raise_error(Choosy::ConfigurationError, /Unknown conversion/)
      end
    end#cast

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

    describe :validate do
      it "should save the context of the validation in a Proc to call later" do
        @builder.validate do
          puts "Hi!"
        end
        @option.validation_step.should be_a(Proc)
      end
      
      it "should have access to the larger context when called" do
        value = nil
        @builder.validate do
          value = 'here'
        end
        @option.validation_step.call
        value.should eql('here')
      end
    end#validate

    describe :finalize! do
      it "should set the arity if not already set" do
        @builder.short '-s'
        @builder.finalize!
        @option.arity.should eql(0..0)
      end

      it "should set the cast to :string on regular arguments" do
        @builder.short '-s', 'SHORT'
        @builder.finalize!
        @option.cast_to.should eql(:string)
      end

      it "should set the cast to :boolean on single flags" do
        @builder.short '-s'
        @builder.finalize!
        @option.cast_to.should eql(:boolean)
      end
    end#finalize!

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
