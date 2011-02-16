require 'spec_helpers'
require 'choosy/converter'

module Choosy
  describe Converter do

    describe "for types" do
      it "knows about Files" do
        Converter.for_type(File).should eql(:file)
      end

      it "knows about Integers" do
        Converter.for_type(Integer).should eql(:integer)
      end

      it "knows about Float" do
        Converter.for_type(Float).should eql(:float)
      end

      it "knows about Symbols" do
        Converter.for_type(Symbol).should eql(:symbol)
      end

      it "should know about Date" do
        Converter.for_type(Date).should eql(:date)
      end

      it "should know about Time" do
        Converter.for_type(Time).should eql(:time)
      end

      it "should know about DateTime" do
        Converter.for_type(DateTime).should eql(:datetime)
      end
    end
  end
end
