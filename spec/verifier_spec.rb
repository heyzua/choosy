require 'spec_helpers'
require 'choosy/verifier'
require 'choosy/errors'
require 'choosy/parser'
require 'choosy/command'

module Choosy

  module VerifierHelper
    def v(cb)
      Verifier.new(cb.command.options)
    end
  end

  describe Verifier do
    include VerifierHelper

    before :each do
      @cb = Command.new(:verifier).builder
      @res = ParseResult.new
    end

    describe :populate_defaults! do
      it "should fill in default boolean values to false if unset" do
        @cb.boolean :debug, "Debug"
        v(@cb).populate_defaults!(@res)
        @res.options.should eql({:debug => false})
      end

      it "should fill in the default boolean to true if set to true" do
        @cb.boolean :verbose, "Verbose", :default => true
        v(@cb).populate_defaults!(@res)
        @res.options.should eql({:verbose => true})
      end

      it "should set the default of multi-arg options to []" do
        @cb.strings :words, "Words"
        v(@cb).populate_defaults!(@res)
        @res.options.should eql({:words => []})
      end

      it "should set the default value for other options to nil if empty" do
        @cb.string :line, "Line"
        v(@cb).populate_defaults!(@res)
        @res.options.should eql({:line => nil})
      end

      it "should set the default value for other options if set" do
        @cb.string :line, "Line", :default => "line!"
        v(@cb).populate_defaults!(@res)
        @res.options.should eql({:line => "line!"})
      end
    end#populate_defaults!

    describe :validate_options! do
      it "should call the validate proc associated with each option" do
        @cb.string :line, "Line" do |l|
          l.validate do |arg|
            l.fail "Validated!"
          end
        end
        @res[:line] = "line"

        attempting {
          v(@cb).validate_options!(@res)
        }.should raise_error(Choosy::ValidationError, /Validated!/)
      end
    end
  end
end
