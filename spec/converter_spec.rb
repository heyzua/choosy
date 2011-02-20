require 'spec_helpers'
require 'choosy/converter'

module Choosy
  describe Converter do

    describe :for do
      
      describe "types" do
        it "knows about Strings" do
          Converter.for(String).should eql(:string)
        end
        
        it "knows about Files" do
          Converter.for(File).should eql(:file)
        end

        it "knows about Integers" do
          Converter.for(Integer).should eql(:integer)
        end

        it "knows about Float" do
          Converter.for(Float).should eql(:float)
        end

        it "knows about Symbols" do
          Converter.for(Symbol).should eql(:symbol)
        end

        it "should know about Date" do
          Converter.for(Date).should eql(:date)
        end

        it "should know about Time" do
          Converter.for(Time).should eql(:time)
        end

        it "should know about DateTime" do
          Converter.for(DateTime).should eql(:datetime)
        end
      end

      describe "symbols" do
        it "knows about strings" do
          Converter.for(:string).should eql(:string)
        end
        
        it "knows about files" do
          Converter.for(:file).should eql(:file)
        end

        it "knows about ints" do
          Converter.for(:int).should eql(:integer)
        end

        it "knows about integers" do
          Converter.for(:integer).should eql(:integer)
        end

        it "knows about floats" do
          Converter.for(:float).should eql(:float)
        end

        it "knows about Dates" do
          Converter.for(:date).should eql(:date)
        end

        it "knows about Time" do
          Converter.for(:time).should eql(:time)
        end

        it "knows about DateTime" do
          Converter.for(:datetime).should eql(:datetime)
        end
      end

      describe "unknown types" do
        it "returns nil" do
          Converter.for(Hash).should be(nil)
        end
      end

      describe "unknown symbols" do
        it "returns nil" do
          Converter.for(:tada).should be(nil)
        end
      end

      describe "booleans" do
        it "returns :boolean on :boolean" do
          Converter.for(:boolean).should eql(:boolean)
        end

        it "returns :boolean on :bool" do
          Converter.for(:bool).should eql(:boolean)
        end
      end
    end#for
  end
end
