require 'spec_helpers'
require 'choosy/converter'

module Choosy
  describe Converter do

    describe :for do
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

    describe "converting" do
      describe :integer do
        it "should return an integer value" do
          Converter.convert(:integer, "42").should eql(42)
        end
      end

      describe :float do
        it "should return an float value" do
          Converter.convert(:float, "3.2").should eql(3.2)
        end
      end

      describe :symbol do
        it "should return a symbol" do
          Converter.convert(:symbol, "this").should eql(:this)
        end
      end

      describe :file do
        it "should return a file" do
          Converter.convert(:file, __FILE__).path.should eql(__FILE__)
        end
      end

      describe :date do
        it "should return a Date" do
          date = Converter.convert(:date, "July 17, 2010")
          date.month.should eql(7)
          date.day.should eql(17)
          date.year.should eql(2010)
        end
      end

      describe :time do
        it "should return a Time" do
          time = Converter.convert(:time, "12:30:15")
          time.hour.should eql(12)
          time.min.should eql(30)
          time.sec.should eql(15)
        end
      end

      describe :datetime do
        it "should return a DateTime" do
          datetime = Converter.convert(:datetime, "July 17, 2010 12:30:15")
          datetime.month.should eql(7)
          datetime.day.should eql(17)
          datetime.year.should eql(2010)
          datetime.hour.should eql(12)
          datetime.min.should eql(30)
          datetime.sec.should eql(15)
        end
      end
    end#converting
  end
end
