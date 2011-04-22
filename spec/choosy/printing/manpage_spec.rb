require 'choosy/printing/manpage'
require 'spec_helpers'

module Choosy::Printing
  describe ManpageFormatter do
    before :each do 
      @format = ManpageFormatter.new
    end

    it "should format bold" do
      @format.bold("this").should eql('\\fBthis\\fP')
    end

    it "should format simple bold" do
      @format.bold.should eql('\\fB')
    end

    it "should format italics" do
      @format.italics('this').should eql('\\fIthis\\fP')
    end

    it "should format simple italics" do
      @format.italics.should eql('\\fI')
    end

    it "should format roman" do
      @format.roman('this').should eql('\\fRthis\\fP')
    end

    it "should format simple roman" do
      @format.roman.should eql('\\fR')
    end
  end

  describe Manpage do
    before :each do
      @man = Manpage.new
    end

    it "should format the frame outlines correctly" do
      @man.name = 'named'
      @man.date = 'today'
      @man.version = 'version'
      @man.manual = 'manual'

      @man.frame_outline.should eql('.TH "named" "1" "today" "version" "manual"')
    end

    it "should format a section heading correctly" do
      @man.section_heading("Header:").should eql(%Q{.SH "HEADER"})
    end

    it "should format a sub-section heading correctly" do
      @man.subsection_heading('Sub-Section:').should eql(%Q{.SS "SUB\\-SECTION"})
    end

    it "should add a paragraph break" do
      @man.paragraph.should eql(".P")
    end
    
    it "should attach the line after the paragraph" do
      @man.paragraph("some text").should eql(".P\nsome text")
    end

    it "should handle indented paragraphs" do
      @man.indented_paragraph("this is a", "goes here").should eql(%Q{.IP "this is a"\ngoes here})
    end

    it "should handle hanging paragraphs" do
      @man.hanging_paragraph("this is a paragraph").should eql(%Q{.HP\nthis is a paragraph})
    end

    it "should handle an indented region" do
      @man.indented_region.should eql('.RE')
    end

    describe :bold do
      it "should allow for bolded text" do
        @man.bold("line").should eql('.B "line"')
      end

      it "should allow for bold alternating with italics" do
        @man.bold("line", :italics).should eql('.BI "line"')
      end

      it "should allow for bold alternating with roman" do
        @man.bold("line", :roman).should eql('.BR "line"')
      end

      it "should fail on unrecognized type" do
        attempting {
          @man.bold("line", :blah)
        }.should raise_error(Choosy::ConfigurationError, /bold/)
      end
    end

    describe :italics do
      it "should allow for italicized text" do
        @man.italics("line").should eql('.I "line"')
      end

      it "should allow for alternating bold" do
        @man.italics("line", :bold).should eql('.IB "line"')
      end

      it "should allow for alternating roman" do
        @man.italics("line", :roman).should eql('.IR "line"')
      end

      it "should fail on unrecognized type" do
        attempting {
          @man.italics("line", :blah)
        }.should raise_error(Choosy::ConfigurationError, /italics/)
      end
    end

    describe :roman do
      it "should allow for alternating bold text" do
        @man.roman("line", :bold).should eql('.RB "line"')
      end

      it 'should allow for alternating italics text' do
        @man.roman("line", :italics).should eql('.RI "line"')
      end

      it "should fail when the type isn't given" do
        attempting {
          @man.roman("line", nil)
        }.should raise_error(Choosy::ConfigurationError, /roman/)
      end
    end

    describe :small do
      it "should allow for small text" do
        @man.small("this").should eql('.SM "this"')
      end

      it "should allow for small bold text" do
        @man.small("this", :bold).should eql('.SB "this"')
      end

      it "should fail when not bold" do
        attempting {
          @man.small("this", :blah)
        }.should raise_error(Choosy::ConfigurationError, /small/)
      end
    end

    it "should allow for comments" do
      @man.comment("here").should eql('.\\" here')
    end

    it "should allow for line breaks" do
      @man.line_break.should eql('.br')
    end

    it "should allow for nofill" do
      @man.nofill.should eql('.nf')
    end

    it "should allow for blocks of no-fill" do
      @man.nofill do |man|
        man.text 'here'
      end
      @man.buffer.join("\n").should eql(".nf\nhere\n.fi")
    end

    it "should allow for fill" do
      @man.fill.should eql('.fi')
    end

    describe :term_paragraph do
      it "should allow for a default width within the term" do
        @man.term_paragraph("this", "that").should eql(%Q{.TP 5\nthis\nthat})
      end

      it "should allow you to set the first column width" do
        @man.term_paragraph("this", "that", 10).should eql(%Q{.TP 10\nthis\nthat})
      end
    end

    describe :to_s do
      it "should write out everything to a string" do
        @man.name = "blah"
        @man.date = 'today'

        @man.column_width = 100
        @man.section_heading('description')
        @man.paragraph('this is a line of text')

        @man.to_s.should eql(<<EOF
'\\" t
.TH "blah" "1" "today" " " " "
.ie \\n(.g .ds Aq \\(aq
.el       .ds Aq '
.\\" disable hyphenation
.nh
.\\" disable justification (adjust text to left margin only)
.ad l
.ll 100
.SH "DESCRIPTION"
.P
this is a line of text
EOF
        )
      end
    end
  end
end
