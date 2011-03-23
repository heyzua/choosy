require 'choosy/printing/manpage'

module Choosy::Printing
  class ManPageHelper
    include Manpage
  end

  describe Manpage do
    before :each do
      @man = ManPageHelper.new
    end

    it "should format the frame outlines correctly" do
      @man.frame('foo', 1, 'March 2011', 'Ruby', 'User Manual')
        .should eql(%Q{.TH FOO 1 "March 2011" "Ruby" "User Manual"\n})
    end

    it "should format a header correctly" do
      @man.header("Header:").should eql(".SH HEADER\n")
    end

  end
end
