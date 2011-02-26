require 'spec_helpers'
require 'choosy/verifier'
require 'choosy/errors'
require 'choosy/parser'
require 'choosy/command'

module Choosy

  module VerifierHelper
    def reset!
      @c = Command.new(:verifier)
    end

    def v
      Verifier.new(@c)
    end

    def b
      @c.builder
    end
  end

  describe Verifier do
    include VerifierHelper

    before :each do
      reset!
      @res = ParseResult.new
    end

    describe :verify! do
      it "should not try to validate arguments if not set" do
        b.boolean :debug, "Debug"
        @res.args << "a"
        attempting {
          v.verify!(@res)
        }.should_not raise_error
      end

      it "should validate arguments if asked" do
        b.arguments do |args|
          raise RuntimeError.new('Called!')
        end

        attempting {
          v.verify!(@res)
        }.should raise_error(RuntimeError, 'Called!')
      end
    end

    describe :populate! do
      it "should fill in default boolean values to false if unset" do
        o = b.boolean :debug, "Debug"
        v.populate!(o, @res)
        @res.options.should eql({:debug => false})
      end

      it "should fill in the default boolean to true if set to true" do
        o = b.boolean :verbose, "Verbose", :default => true
        v.populate!(o, @res)
        @res.options.should eql({:verbose => true})
      end

      it "should set the default of multi-arg options to []" do
        o = b.strings :words, "Words"
        v.populate!(o, @res)
        @res.options.should eql({:words => []})
      end

      it "should set the default value for other options to nil if empty" do
        o = b.string :line, "Line"
        v.populate!(o, @res)
        @res.options.should eql({:line => nil})
      end

      it "should set the default value for other options if set" do
        o = b.string :line, "Line", :default => "line!"
        v.populate!(o, @res)
        @res.options.should eql({:line => "line!"})
      end
    end#populate_defaults!

    describe :validate! do
      it "should call the validate proc associated with each option" do
        o = b.string :line, "Line" do |l|
          l.validate do |arg|
            l.fail "Validated!"
          end
        end
        @res[:line] = "line"

        attempting {
          v.validate!(o, @res)
        }.should raise_error(Choosy::ValidationError, /Validated!/)
      end

      it "should not call the proc on empty arguments" do
        o = b.strings :line, "Line" do |l|
          l.validate do |arg|
            l.fail "Validated!"
          end
        end
        @res[:line] = []

        v.validate!(o, @res)
        @res[:line].should eql([])
      end

      it "should not call the proc when the arguments are null" do
        o = b.string :line, "Line" do |l|
          l.validate do |arg|
            l.fail "Validated!"
          end
        end
        @res[:line] = nil

        v.validate!(o, @res)
        @res[:line].should be(nil)
      end
    end#validate!

    describe :convert! do
      it "should convert files" do
        o = b.file :afile, "A File"
        @res[:afile] = __FILE__
        v.convert!(o, @res)
        @res[:afile].path.should eql(__FILE__)
      end

      class CustomConverter
        def convert(value)
          value.to_i
        end
      end

      it "should convert a custom type" do
        o = b.single :an_int, "An int" do |i|
          i.cast CustomConverter.new
        end
        @res[:an_int] = "1"

        v.convert!(o, @res)
        @res[:an_int].should eql(1)
      end
    end
  end
end
